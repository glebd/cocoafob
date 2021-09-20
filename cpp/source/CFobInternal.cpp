//
//  CFobInternal.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-08-25.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "CFobInternal.hpp"

namespace CFob
{
    namespace Internal
    {

auto StripFormattingFromBase32EncodedString(UTF8String formattedString) -> UTF8String
{
    // Replace 9s with Is and 8s with Os
    std::replace( formattedString.begin(), formattedString.end(), '9', 'I');
    std::replace( formattedString.begin(), formattedString.end(), '8', 'O');

    // Remove dashes from the registration key if they are there (dashes are optional).
    formattedString.erase(std::remove(formattedString.begin(),
                                     formattedString.end(),
                                     '-'),
                         formattedString.end());

    const auto keyLength = formattedString.length();
    const auto paddedLength = keyLength%8 ? ((keyLength/8 + 1)*8) - keyLength : 0;

    if (paddedLength > 0)
    {
        formattedString.append(paddedLength, '=');
    }

    return formattedString;
}

auto FormatBase32EncodedString(UTF8String stringToFormat) -> UTF8String
{
    // Replace 9s with Is and 8s with Os
    std::replace( stringToFormat.begin(), stringToFormat.end(), 'I', '9');
    std::replace( stringToFormat.begin(), stringToFormat.end(), 'O', '8');

    // Remove dashes from the registration key if they are there (dashes are optional).
    stringToFormat.erase(std::remove(stringToFormat.begin(),
                                     stringToFormat.end(),
                                     '='),
                         stringToFormat.end());

    auto index      = 5;
    const auto dash = UTF8String{"-"};
    while(index < stringToFormat.length())
    {
        stringToFormat.insert(index, dash);
        index += 6;
    }
    return stringToFormat;
}

    } // Internal
} // CFob