
#include <iostream>
#include <fstream>
#include <list>
#include <string>

#include "zypp/base/Logger.h"
#include "zypp/base/Exception.h"
#include "zypp/KeyRing.h"
#include "zypp/PublicKey.h"
#include "zypp/TmpPath.h"

#include <boost/test/unit_test.hpp>
#include <boost/test/parameterized_test.hpp>
#include <boost/test/unit_test_log.hpp>

#include "KeyRingTestReceiver.h"

using boost::unit_test::test_suite;
using boost::unit_test::test_case;
using namespace boost::unit_test::log;

using namespace std;
using namespace zypp;
using namespace zypp::filesystem;

void keyring_test( const string &dir )
{
  PublicKey key( Pathname(dir) + "public.asc" );
  
  

 /** 
  * scenario #1
  * import a not trusted key
  * ask for trust, answer yes
  * ask for import, answer no
  */
  {
    KeyRingTestReceiver keyring_callbacks;
    KeyRingTestSignalReceiver receiver;
    // base sandbox for playing
    TmpDir tmp_dir;
    KeyRing keyring( tmp_dir.path() );

    BOOST_CHECK_EQUAL( keyring.publicKeys().size(), (unsigned) 0 );
    BOOST_CHECK_EQUAL( keyring.trustedPublicKeys().size(), (unsigned) 0 );
  
    keyring.importKey( key, false );
    
    BOOST_CHECK_EQUAL( keyring.publicKeys().size(), (unsigned) 1 );
    BOOST_CHECK_EQUAL( keyring.trustedPublicKeys().size(), (unsigned) 0 );
    
    BOOST_CHECK_MESSAGE( keyring.isKeyKnown( key.id() ), "Imported untrusted key should be known");
    BOOST_CHECK_MESSAGE( ! keyring.isKeyTrusted( key.id() ), "Imported untrusted key should be untrusted");
    
    keyring_callbacks.answerTrustKey(true);
    bool to_continue = keyring.verifyFileSignatureWorkflow( Pathname(dir) + "repomd.xml", "Blah Blah", Pathname(dir) + "repomd.xml.asc");
  
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptUnknownKey(), "Should not ask for unknown key, it was known");
    BOOST_CHECK_MESSAGE( keyring_callbacks.askedTrustKey(), "Verify Signature Workflow with only 1 untrusted key should ask user wether to trust");
    BOOST_CHECK_MESSAGE( keyring_callbacks.askedImportKey(), "Trusting a key should ask for import");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptVerFailed(), "The signature validates");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptUnsignedFile(), "It is a signed file, so dont ask the opposite");
    
    BOOST_CHECK_MESSAGE( to_continue, "We did not import, but we trusted and signature validates.");
  }
  
  /** 
  * scenario #1.1
  * import a not trusted key
  * ask for trust, answer yes
  * ask for import, answer no
  * vorrupt the file and check
  */
  {
    KeyRingTestReceiver keyring_callbacks;
    KeyRingTestSignalReceiver receiver;
    // base sandbox for playing
    TmpDir tmp_dir;
    KeyRing keyring( tmp_dir.path() );
    
    BOOST_CHECK_EQUAL( keyring.publicKeys().size(), (unsigned) 0 );
    BOOST_CHECK_EQUAL( keyring.trustedPublicKeys().size(), (unsigned) 0 );
  
    keyring.importKey( key, false );
    
    keyring_callbacks.answerTrustKey(true);
    
    // now we will recheck with a corrupted file
    bool to_continue = keyring.verifyFileSignatureWorkflow( Pathname(dir) + "repomd.xml.corrupted", "Blah Blah", Pathname(dir) + "repomd.xml.asc");
    
    // check wether the user got the right questions
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptUnknownKey(), "Should not ask for unknown key, it was known");
    BOOST_CHECK_MESSAGE( keyring_callbacks.askedTrustKey(), "Verify Signature Workflow with only 1 untrusted key should ask user wether to trust");
    BOOST_CHECK_MESSAGE( keyring_callbacks.askedImportKey(), "Trusting a key should ask for import");
    BOOST_CHECK_MESSAGE( keyring_callbacks.askedAcceptVerFailed(), "The signature does not validates");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptUnsignedFile(), "It is a signed file, so dont ask the opposite");
    
    BOOST_CHECK_MESSAGE( ! to_continue, "We did not continue with a corrupted file");
  }
  
   /** 
  * scenario #1.2
  * import a not trusted key
  * ask for trust, answer yes
  * ask for import, answer no
  * check without signature
  */
  {
    KeyRingTestReceiver keyring_callbacks;
    KeyRingTestSignalReceiver receiver;
    // base sandbox for playing
    TmpDir tmp_dir;
    KeyRing keyring( tmp_dir.path() );
    
    keyring.importKey( key, false );
    
    keyring_callbacks.answerTrustKey(true);
    // now we will recheck with a unsigned file
    bool to_continue = keyring.verifyFileSignatureWorkflow( Pathname(dir) + "repomd.xml", "Blah Blah", Pathname() );
    
    // check wether the user got the right questions
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptUnknownKey(), "Should not ask for unknown key, it was known");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedTrustKey(), "No signature, no key to trust");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedImportKey(), "No signature, no key to import");
    BOOST_CHECK_MESSAGE( keyring_callbacks.askedAcceptUnsignedFile(), "Ask the user wether to accept an unsigned file");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptVerFailed(), "There is no signature to verify");
    
    BOOST_CHECK_MESSAGE( ! to_continue, "We did not continue with a unsigned file");
  }
  
 /** scenario #2
  * empty keyring
  * should ask for unknown key
  * answer no
  */
  {
    KeyRingTestReceiver keyring_callbacks;
    KeyRingTestSignalReceiver receiver;
    // base sandbox for playing
    TmpDir tmp_dir;
    KeyRing keyring( tmp_dir.path() );
    
    BOOST_CHECK_MESSAGE( ! keyring.isKeyKnown( key.id() ), "empty keyring has not known keys");
    
    //keyring_callbacks.answerAcceptUnknownKey(true);
    bool to_continue = keyring.verifyFileSignatureWorkflow( Pathname(dir) + "repomd.xml", "Blah Blah", Pathname(dir) + "repomd.xml.asc");
    BOOST_CHECK_MESSAGE(keyring_callbacks.askedAcceptUnknownKey(), "Should ask to accept unknown key, empty keyring");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedTrustKey(), "Unknown key cant be trusted");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedImportKey(), "Unknown key cant be imported");
    
    BOOST_CHECK_MESSAGE( ! to_continue, "We answered no to accept unknown key");
  }
  
  /** scenario #3
  * import trusted key
  * should ask nothing
  * should emit signal
  */
  {
    KeyRingTestReceiver keyring_callbacks;
    KeyRingTestSignalReceiver receiver;
    // base sandbox for playing
    TmpDir tmp_dir;
    KeyRing keyring( tmp_dir.path() );
    
    BOOST_CHECK_EQUAL( keyring.publicKeys().size(), (unsigned) 0 );
    BOOST_CHECK_EQUAL( keyring.trustedPublicKeys().size(), (unsigned) 0 );
  
    keyring.importKey( key, true );
    
    BOOST_CHECK_EQUAL( receiver._trusted_key_added_called, true );
    
    BOOST_CHECK_EQUAL( keyring.publicKeys().size(), (unsigned) 0 );
    BOOST_CHECK_EQUAL( keyring.trustedPublicKeys().size(), (unsigned) 1 );
    
    BOOST_CHECK_MESSAGE( keyring.isKeyKnown( key.id() ), "Imported trusted key should be known");
    BOOST_CHECK_MESSAGE( keyring.isKeyTrusted( key.id() ), "Imported trusted key should be trusted");
    
    bool to_continue = keyring.verifyFileSignatureWorkflow( Pathname(dir) + "repomd.xml", "Blah Blah", Pathname(dir) + "repomd.xml.asc");
  
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptUnknownKey(), "Should not ask for unknown key, it was known");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedTrustKey(), "Verify Signature Workflow with only 1 untrusted key should ask user wether to trust");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedImportKey(), "Trusting a key should ask for import");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptVerFailed(), "The signature validates");
    BOOST_CHECK_MESSAGE( ! keyring_callbacks.askedAcceptUnsignedFile(), "It is a signed file, so dont ask the opposite");
    
    BOOST_CHECK_MESSAGE( to_continue, "We did not import, but we trusted and signature validates.");
  }
  //keyring.importKey( key, true );
  //BOOST_CHECK_EQUAL( receiver._trusted_key_added_called, true );
  //BOOST_CHECK_EQUAL( keyring.trustedPublicKeys().size(), 1 );

  /* check signature id can be extracted */
  {
    KeyRingTestReceiver keyring_callbacks;
    KeyRingTestSignalReceiver receiver;
    // base sandbox for playing
    TmpDir tmp_dir;
    KeyRing keyring( tmp_dir.path() );
    
    BOOST_CHECK_EQUAL( keyring.readSignatureKeyId( Pathname(dir) + "repomd.xml.asc" ), "BD61D89BD98821BE" );
    BOOST_CHECK_EQUAL( keyring.readSignatureKeyId(Pathname()), "" );
  }
}

test_suite*
init_unit_test_suite( int argc, char* argv[] )
{
  string datadir;
  if (argc < 2)
  {
    datadir = TESTS_SRC_DIR;
    datadir = (Pathname(datadir) + "/zypp/data/KeyRing").asString();
    cout << "keyring_test:"
      " path to directory with test data required as parameter. Using " << datadir  << endl;
    //return (test_suite *)0;
  }
  else
  {
    datadir = argv[1];
  }

  std::string const params[] = { datadir };
    //set_log_stream( std::cout );
  test_suite* test= BOOST_TEST_SUITE( "PublicKeyTest" );
  test->add(BOOST_PARAM_TEST_CASE( &keyring_test,
                              (std::string const*)params, params+1));
  return test;
}

