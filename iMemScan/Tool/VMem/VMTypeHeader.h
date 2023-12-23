//
//  VMTypeHeader.h
//  ViewMem
//
//  Created by HaoCold on 2020/9/2.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#ifndef VMTypeHeader_h
#define VMTypeHeader_h

typedef enum : NSUInteger {
    VMMemValueTypeUnsignedByte   = 1,
    VMMemValueTypeSignedByte     = 2,  // I8
    VMMemValueTypeUnsignedShort  = 3,
    VMMemValueTypeSignedShort    = 4,  // I16
    VMMemValueTypeUnsignedInt    = 5,
    VMMemValueTypeSignedInt      = 6,  // I32
    VMMemValueTypeUnsignedLong   = 7,
    VMMemValueTypeSignedLong     = 8,  // I64
    VMMemValueTypeFloat          = 9,  // F32
    VMMemValueTypeDouble         = 10, // F64
} VMMemValueType;

typedef enum : NSUInteger {
    VMMemComparisonLT, // <
    VMMemComparisonLE, // <=
    VMMemComparisonEQ, // =
    VMMemComparisonGE, // >=
    VMMemComparisonGT, // >
} VMMemComparison;

typedef enum : NSUInteger {
    VMMemSearchType_1 = 1, // 1
    VMMemSearchType_2 = 2, // 2
    VMMemSearchType_4 = 4, // 4
    VMMemSearchType_8 = 8, // 8
} VMMemSearchType;

#endif /* VMTypeHeader_h */
