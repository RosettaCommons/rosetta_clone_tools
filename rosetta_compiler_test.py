#!/usr/bin/env python

"""Rosetta compiler support test.

This script will attempt to test various advanced compiler features which Rosetta uses.

It will produce a report detailing those items which are supported by your compiler
and those which are not.

Call with the compiler you wish to test, along with any flags you need to to turn on C++11 mode.
(Usually -std=c++11 or -std=c++0x but may vary based on compiler.)

     ./rosetta_compiler_test.py /usr/local/bin/g++4.7 -std=c++0x

Be sure to use the C++ compiler (e.g. 'g++' or 'clang++')
rather than the C compiler ('gcc' or 'clang').

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

"CHRONO":
'''#include <chrono>
int main() {
    std::chrono::nanoseconds ns(5);
    std::chrono::system_clock::now();
    return 0;
}''',

"DELETED CONSTRUCTORS":
'''
class X {
public:
    X() = default;
    X( X const & ) = delete;
    X & operator=( X const & ) = delete;
};
int main() { return 0; }''',

"DELEGATING CONSTRUCTORS":
'''
class X {
    int content_;
public:
    X(int x) : content_(x) {};
    X() : X(0) {};
};
int main() { return 0; }''',

"IN-CLASS INITIALIZATION":
'''
class X {
    int integer_ = 0;
    double real_ = 3.14;
    X * parent_ = 0;
};
int main() { return 0; }''',

"OVERRIDE":
'''
struct X {
    virtual int apply() { return 1; }
};
struct Y: public X {
    virtual int apply() override { return 0; }
};

int main() { return Y().apply(); }''',

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
    if ( std::regex_search(s,reg) ) { return 0; }
    else { return 1; }
}''',

"THREAD":
'''#include <thread>
#include <atomic>
int main() {
    std::thread thread1;
    std::atomic_thread_fence( std::memory_order_acquire );
    std::thread::id this_id( std::this_thread::get_id() );
    return 0;
}''',

"ATOMIC":
'''#include <atomic>
class DummyClass {};
int main() {
    std::atomic< DummyClass * > atomic_class;
    return 0;
}''',

"MUTEX":
'''#include <mutex>
int main() {
    std::mutex my_mutex;
    std::lock_guard<std::mutex> lock(my_mutex);
    return 0;
}''',

"CONDITION VARIABLE":
'''#include <condition_variable>
int main() {
    std::condition_variable_any cva;
    return 0;
}''',

}


import sys, os
import subprocess

def run_and_get_errors( command, with_output = False):
    process = subprocess.Popen( command, stdout=subprocess.PIPE, stderr=subprocess.PIPE )
    output, error = process.communicate()
    if with_output:
        return (output+error).strip()
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
            continue
        # Check to make sure it runs appropriately.
        error = run_and_get_errors( ["./rosetta_compiler_test"] )
        if error is not None:
            sys.stdout.write("<<<FAILED! (Compiled but did not run.)>>>\n")
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

    print "Testing compiler '%s', reporting as:" % arguments[0]
    print '\t', run_and_get_errors( [arguments[0], '--version'], True ).split('\n')[0]

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
