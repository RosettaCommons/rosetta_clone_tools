//
// This file is a test program to see if your compiler is able to compile Rosetta.
// To run the test, compile this file with the same compiler you intend to use to compiler Rosetta,
// being sure to enable C++11 mode (usually the `--std=c++11` flag, might be `--std=c++0x`).
// For example:
//
// /usr/local/bin/g++ --std=c++11 -o rosetta_compiler_test rosetta_compiler_test.cc
//
// If you don't have any errors compiling, and when the executable `./rosetta_compiler_test` is run
// it should print a message that your compiler is supported.

#include <iostream>
#include <map>
#include <unordered_map>
#include <memory>

typedef std::shared_ptr< int > intOP;

std::map< int, intOP > get_map() {
	std::unordered_map< int, intOP > mymap { {3, nullptr}, {4, std::make_shared<int>(5)}, {1,nullptr}, {2,std::make_shared<int>(4)} };
	return std::map< int, intOP >( mymap.begin(), mymap.end() );
}

int main() {

	int total(0);
	std::map< int, intOP > const m( get_map() );
	for( auto s: m ) {
		if( s.second ) { total += *s.second; }
	}
	total += *m.at(2);

	if( total == 13 ) std::cout << "\nCongratulations! Your compiler should support Rosetta!\n" << std::endl;
	else std::cout << "\nSorry, your compiler doesn't support Rosetta!\n" << std::endl;
}
