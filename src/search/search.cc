#include <zlib.h>

#include <iostream>
#include <fstream>
#include <string>

#include "common/AddressBook.pb.h"
#include "common/dummy.h"
using namespace std;

// Iterates though all people in the AddressBook and prints info about them.
void ListPeople(const tutorial::AddressBook& address_book) {
  for (int i = 0; i < address_book.person_size(); i++) {
    const tutorial::Person& person = address_book.person(i);

    cout << "Person ID: " << person.id() << endl;
    cout << "  Name: " << person.name() << endl;
    if (person.has_email()) {
      cout << "  E-mail address: " << person.email() << endl;
    }

    for (int j = 0; j < person.phone_size(); j++) {
      const tutorial::PhoneNumber& phone_number = person.phone(j);

      switch (phone_number.type()) {
        case tutorial::PhoneNumber::MOBILE:
          cout << "  Mobile phone #: ";
          break;
        case tutorial::PhoneNumber::HOME:
          cout << "  Home phone #: ";
          break;
        case tutorial::PhoneNumber::WORK:
          cout << "  Work phone #: ";
          break;
      }
      cout << phone_number.number() << endl;
    }
  }
}

// Main function:  Reads the entire address book from a file and prints all
//   the information inside.
int main(int argc, char* argv[]) {
  int ret = 0;

  cout << Dummy::reverse("\ndlrow olleh") << endl;

  gzFile fout = gzopen("/tmp/delme.gz", "wb");
  const char* msg = "Hello world\n";
  gzwrite(fout, msg, strlen(msg));
  gzclose(fout);

  // Verify that the version of the library that we linked against is
  // compatible with the version of the headers we compiled against.
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  if (argc != 2) {
    cerr << "Usage:  " << argv[0] << " ADDRESS_BOOK_FILE" << endl;
    ret = -1;
  }

  if (ret == 0) {
    tutorial::AddressBook address_book;

    // Read the existing address book.
    fstream input(argv[1], ios::in | ios::binary);
    if (!address_book.ParseFromIstream(&input)) {
      cerr << "Failed to parse address book." << endl;
      ret = -1;
    }

    if (ret == 0) {
      ListPeople(address_book);
    }
  }

  // deallocate protobuf stuff
  google::protobuf::ShutdownProtobufLibrary();

  return 0;
}
