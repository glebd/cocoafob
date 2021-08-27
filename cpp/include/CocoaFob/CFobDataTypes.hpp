//
//  CFobDataTypes.hpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-08-25.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#ifndef CFobDataTypes_h
#define CFobDataTypes_h

#include <memory>
#include <openssl/dsa.h>
#include <string>

using ErrorMessage = std::string;
using RegCode      = std::string;
using UTF8String   = std::string;

using BIO_MEM_uptr  = std::unique_ptr<BIO, decltype(&::BIO_free)>;
using DSA_uptr      = std::unique_ptr<DSA, decltype(&::DSA_free)>;

using BIO_MEM_sptr  = std::shared_ptr<BIO>;
using DSA_sptr      = std::shared_ptr<DSA>;


#endif /* CFobDataTypes_h */
