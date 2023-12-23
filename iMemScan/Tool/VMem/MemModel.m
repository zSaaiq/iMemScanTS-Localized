//
//  MemModel.m
//  ViewMem
//
//  Created by HaoCold on 2020/8/27.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "MemModel.h"

@implementation MemModel

- (MemModel *)clone
{
    MemModel *model = [[MemModel alloc] init];
    model.address = _address;
    model.value = _value;
    model.type = _type;
    
    return model;
}

/**
 NSLog(@"%f 小数形式输出浮点数", u.f);
 NSLog(@"%e 指数形式输出浮点数", u.f);
 NSLog(@"%g 以最简短形式输出浮点数", u.f);
 NSLog(@"%5f 以五位小数形式输出浮点数", u.f);
 NSLog(@"%5.3f 小数行书输出, 一共五位, 小数3位\n", u.f);
 
 NSLog(@"%lf 小数形式输出长浮点数", u.f);
 NSLog(@"%le 指数形式输出长浮点数", u.f);
 NSLog(@"%lg 以最短形式输出长浮点数", u.f);
 NSLog(@"%5lf 5位小数形式输出长浮点数", u.f);
 NSLog(@"%5.3lf 5位小数形式输出长浮点数, 其中3位是小数\n", u.f);
*/

- (NSString *)value
{
    if (_value) {
        return _value;
    }
    
    NSString *val = nil;
    NSString *str = [@"0x" stringByAppendingString:_value_16];
    switch (_valueType) {
        case VMMemValueTypeUnsignedByte:
        case VMMemValueTypeSignedByte:      // I8
        case VMMemValueTypeUnsignedShort:
        case VMMemValueTypeSignedShort:     // I16
        case VMMemValueTypeUnsignedInt:
        case VMMemValueTypeSignedInt:       // I32
        case VMMemValueTypeUnsignedLong:
        case VMMemValueTypeSignedLong:      // I64
        {
            val = [NSString stringWithFormat:@"%ld", strtol([str UTF8String], NULL, 16)];
        }break;
        case VMMemValueTypeFloat:{           // F32
            union u {
                Float32 f;
                int32_t i;
            }u;
            
            sscanf([str UTF8String], "%x", &u.i);
            
            val = [NSString stringWithFormat:@"%.7g", u.f];
        }break;
        case VMMemValueTypeDouble:{          // F64
            union u {
                Float64 f;
                int64_t i;
            }u;
            
            sscanf([str UTF8String], "%llx", &u.i);
            
            val = [NSString stringWithFormat:@"%.15le", u.f];
        }break;
        default:
            break;
    }
    
    NSArray *array = [val componentsSeparatedByString:@"."];
    if (array.count > 1 && [array[1] integerValue] == 0) {
        val = array[0];
    }
    
    _value = val;
    return _value;
}

- (NSString*)address {
    if (!_address)
        _address = [NSString stringWithFormat:@"0x%llX", self.o_addr];
    
    return _address;
}

#pragma mark - override

- (BOOL)isEqual:(MemModel *)object
{
#if 1
    return self.o_addr == object.o_addr;
#else
    return [_address isEqualToString:object.address];
#endif
}

@end
