// C++ MODULE: clang-version.cpp
//
// Purpose   : Print version of Clang compiler on stdout.
// Created   : Tuesday, September  2 2025.
// Author    : Pierre Rouleau <prouleau001@gmail.com>
// Time-stamp: <2025-09-02 11:17:57 EDT, updated by Pierre Rouleau>
// Copyright © 2025, Pierre Rouleau
// License   : GPL-3.0
//
// -----------------------------------------------------------------------------
// Module Description
// ------------------
//
// A small single file utility that prints the version of Clang on stdout by
// invoking 'clang --version' inside a sub-shell and parsing the output.
//
// Since this program stands inside one C++ file, it can be compiled and linked
// with GNU make if the file is stored inside a directory with the same name and
// the command 'make clang-version' is used to build it.
//
// The clang-version shell script, located in "$USRHOME_DIR/bin" checks for the
// presence of the executable and use it if present, otherwise it builds the
// executable first and then uses it.

// -----------------------------------------------------------------------------
// Header Inclusion
// ----------------
#include <iostream>
#include <string>
#include <cstdio>      // use: popen, pclose

// -----------------------------------------------------------------------------
// Local Variables
// ---------------

const char* usage = "clang-version: print clang version on stdout.\n \
  USAGES:\n\
    - clang-version -h|--help\n\
       Print this help.\n\
\n\
    - clang-version [--major]\n\
       Print clang version number on stdout.\n\
       Something like: 16.0.0\n\
       - with -major option: only print major number.\n\
\n\
   BUGS: minimal parsing; does not report invalid arguments.";

// -----------------------------------------------------------------------------
// Code
// ----

int main(int argc, const char** argv)
{
   if ((argc > 1)
       && ((strcmp(argv[1], "-h") == 0) || (strcmp(argv[1], "--help") == 0)))
   {
      std::cout << usage << std::endl;
      return 0;
   }

   FILE* pipe = popen("clang --version", "r");
   if (!pipe)
   {
      std::cerr << "*** " << argv[0] << ": Error piping 'clang --version'" << std::endl;
      return 1;
   }

   char        buffer[128];
   std::string result = "";
   while (fgets(buffer, sizeof(buffer), pipe) != nullptr)
   {
      result += buffer;
   }
   pclose(pipe);

   // clang --version outputs many lines which include something like
   // "Clang version X.Y.Z" or "Apple LLVM version X.Y.Z".
   // Skip all text until the word 'version' and then extract the number.
   size_t pos = result.find("version ");

   if (pos != std::string::npos)
   {
      std::string version_str = result.substr(pos + 8); // skip 'version '
      const char* pattern     = (argc>1 && strcmp(argv[1], "--major") == 0)? "0123456789" : "0123456789.";

      size_t end_pos = version_str.find_first_not_of(pattern);
      if (end_pos != std::string::npos) {
         version_str = version_str.substr(0, end_pos);
      }
      std::cout << version_str << std::endl;
    }
    else
    {
       std::cerr << "*** ERROR: "
                 << argv[0]
                 << " could not find Clang version in 'clang --version' output."
                 << std::endl;
       return 1;
    }
    return 0;
}

// -----------------------------------------------------------------------------
