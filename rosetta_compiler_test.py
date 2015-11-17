#!/usr/bin/env python

"""Rosetta compiler support test.

This script will attempt to test various advanced compiler features which Rosetta uses.

It will produce a report detailing those items which are supported and those which are not by your compiler.

Call with the compiler you wish to test, along with any flags you need to to turn on C++11 mode.
(Usually -std=c++11 or -std=c++0x but may vary based on compiler.

     ./rosetta_compiler_test.py /usr/local/bin/g++4.7 -std=c++0x

Be sure to use the C++ compiler (e.g. 'g++' or 'clang++') rather than the C compiler ('gcc' or 'clang').
Clang users may want to try adding '-stdlib=libc++' and see if that helps things.

You can pass '-v' to get details about the errors.

"""

TESTS = {

"AUTO":
'''
int main() {
    int m(0);
    auto s(m);
    return s;
}''',

"RANGE FOR":
'''#include <vector>
int main() {
    std::vector<int> v(4,2);
    for( int s: v ) { ; }
    return 0;
}''',

"MAP AT()":
'''#include <map>
int main() {
    std::map<int,int> m;
    m[1] = 0;
    return m.at(1);
}''',

"INITIALIZER LIST":
'''#include <vector>
#include <map>
int main() {
    std::vector<int> v = {1,2,3,4,5};
    std::map<int,float> m = { {1,1.1}, {2,2.2}, {3,3.3},{4,4.4}, {5,5.5} };
    return 0;
}''',

"UNORDERED MAP":
'''#include <unordered_map>
int main() {
    std::unordered_map<int,int> um;
    um[1] = 0;
    return um[1];
}''',

"SMART POINTERS":
'''#include <memory>
int main() {
    typedef std::shared_ptr< int > intOP;
    intOP x( new int(0) );
    return *x;
}''',

"NULLPTR":
'''#include <memory>
int main() {
    int* x( nullptr );
    return 0;
}''',

"MOVE":
'''#include <utility>
class Movable {
    int content_;
    public:
    Movable( int val, int val2 ): content_(val) {}
    Movable( Movable && rval ) {
        std::swap(content_, rval.content_);
    }
};
int main() {
    Movable y( Movable(3,4) ); // Memory leak.
    return 0;
}''',

"LAMBDA":
'''#include <algorithm>
#include <vector>
int main() {
    std::vector<int> v = {1, 2, 3, 4, 5, 6, 7};
    int x = 4;
    v.erase(std::remove_if(v.begin(), v.end(), [x](int n) { return n < x; }), v.end());
    return 0;
}''',

}

OPTIONAL_TESTS = {

"THREAD LOCAL":
'''
int main() {
    thread_local int x(0);
    return 0;
}''',

"REGEX":
'''#include <regex>
#include <string>
int main() {
    std::string s("find substring");
    std::regex reg("sub");
    if ( std::regex_search(s,reg) ) { return 1; }
    else { return 0; }
}''',

}


import sys, os
import subprocess

def run_and_get_errors( command ):
    process = subprocess.Popen( command, stdout=subprocess.PIPE, stderr=subprocess.PIPE )
    output, error = process.communicate()
    if process.returncode == 0:
        return None
    elif error:
        return error
    else:
        return "UNKNOWN ERROR\n"

def run_tests( tests, arguments, padding ):
    errors = {}
    for test in sorted(tests.keys()):
        outfile = open("rosetta_compiler_test.cc","w")
        try:
            outfile.write(tests[test])
        finally:
            outfile.close()

        sys.stdout.write((test+':').ljust(padding) + '\t')
        sys.stdout.flush()
        error = run_and_get_errors( arguments + [ "rosetta_compiler_test.cc", '-o', "rosetta_compiler_test" ] )
        if error is not None:
            sys.stdout.write("<<<FAILED!>>>\n")
            errors[ test ] = error
        else:
            sys.stdout.write("Pass.\n")
    return errors


def main(arguments, verbose):
    # Test if the compiler will work
    error = run_and_get_errors( [arguments[0], '--version'] )
    if error is not None:
        print "ERROR: Compiler '%s' doesn't seem to be working. Check path and name." % arguments[0]
        print error
        exit(-1)

    print "Testing compiler '%s' ..." % ' '.join(arguments)

    name_size = max( [len(t)+1 for t in TESTS.keys() + OPTIONAL_TESTS.keys()] )

    print "\nMain tests:\n"
    errors = run_tests( TESTS, arguments, name_size )

    print "\nOptional tests (not needed for standard compiles, but for extra features like multithreading):\n"
    optional_errors = run_tests( OPTIONAL_TESTS, arguments, name_size )

    if (verbose or len(errors) == len(TESTS) ) and (len(errors) or len(optional_errors)):
        print '\n'+ 70*'-'
        print "\nDetailed error messages:"
        for test in errors:
            print "============", test, "============"
            print errors[test]
            print
        for test in optional_errors:
            print "============", test, "============"
            print optional_errors[test]
            print
        print 70*'-'

    print
    print "Summary:"
    print "Main Tests:".ljust(name_size)+'\t', len(TESTS) - len(errors), "of", len(TESTS), "passed"
    print "Optional Tests:".ljust(name_size)+'\t', len(OPTIONAL_TESTS) - len(optional_errors), "of", len(OPTIONAL_TESTS), "passed"
    if len(errors) != 0:
        print "\nSorry, your compiler has issues which prevent it from compiling Rosetta - try updating your compiler or altering settings.\n"
    elif len(optional_errors) != 0:
        print "\nYour compiler should work for standard Rosetta compilation, but may not work with all extras builds.\n"
    else:
        print "\nCongratulations! Your compiler should support Rosetta!\n"

if __name__ == "__main__":
    arguments = sys.argv
    if '-v' in arguments:
        verbose = True
        arguments.remove('-v')
    else:
        verbose = False
    if len(arguments) == 1:
        print __doc__
        exit(-1)
    else:
        main(arguments[1:], verbose)
