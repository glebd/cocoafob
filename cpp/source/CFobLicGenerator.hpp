//
//  CFobLicGenerator.hpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-17.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#ifndef CFobLicGenerator_hpp
#define CFobLicGenerator_hpp

#include <string>
#include <tuple>

using ErrorMessage = std::string;
using RegCode      = std::string;
using UTF8String   = std::string;

class CFobLicGenerator;

/*
 Factory function, which will check if the private key
 is valid before returning an instance to CFobLicGenerator.
 */
template <typename T = std::shared_ptr<CFobLicGenerator> >
T CreateCFobLicGenerator(const UTF8String privateKey )
{
    if (privateKey.length() == 0)
        return T{};
    
    return T{};
}

/*
 Class follows model created in Swift
 */
class CFobLicGenerator
{
public:

    
    auto SetPrivateKey() -> std::tuple<bool, ErrorMessage>;
    
    auto GenerateRegCodeForName(const std::string name) -> std::tuple<bool, RegCode>;
    
private:
    template <typename T>
    friend T CreateCFobLicGenerator(const UTF8String privateKey );
    
    CFobLicGenerator(const std::string privateKey);
    
    CFobLicGenerator() = delete;
    const UTF8String _privateKey;
};


#endif /* CFobLicGenerator_hpp */
