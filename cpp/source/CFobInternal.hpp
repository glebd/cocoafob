//
//  CFobInternal.hpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-08-25.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#ifndef CFobInternal_hpp
#define CFobInternal_hpp

#include "CFobDataTypes.hpp"

namespace CFob
{
    namespace Internal
    {
        auto StripFormattingFromBase32EncodedString(UTF8String stringToFormat) -> UTF8String;
        auto FormatBase32EncodedString(UTF8String stringToFormat) -> UTF8String;
    }
}

#endif /* CFobInternal_hpp */
