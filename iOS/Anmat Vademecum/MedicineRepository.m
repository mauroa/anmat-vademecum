//
//  MedicineRepository.m
//  Anmat Vademecum
//
//  Created by mag on 3/16/15.
//  Copyright (c) 2015 Think Up Studios. All rights reserved.
//

#import "MedicineRepository.h"
#import "Medicine.h"
#import "DataBaseProvider.h"
#import "String.h"

@implementation MedicineRepository

-(NSArray *) getAll {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    sqlite3 *database = [[DataBaseProvider instance] getDataBase];
    NSString *query = @"SELECT * FROM medicamentos ORDER BY hospitalario ASC, precio ASC";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Medicine *medicine = [self getMedicine:statement];
            
            [result addObject:medicine];
        }
        
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
    
    return result;
}

-(NSArray *) getAll:(NSString *)genericName comercialName:(NSString *)comercialName laboratory:(NSString *)laboratory {
    BOOL conditionStarted = NO;
    NSMutableString *query = [[NSMutableString alloc] init];
    
    [query appendString:@"SELECT * FROM medicamentos WHERE "];
    
    if(genericName != nil && genericName.length > 0) {
        BOOL containsOrExpression = [self containsOrExpression:genericName];
        BOOL containsAndExpression = [self containsAndExpression:genericName];
        
        if(containsOrExpression || containsAndExpression) {
            NSMutableString *logicExpression = [[NSMutableString alloc] init];
            
            [logicExpression appendString:@"("];
            
            if(containsOrExpression) {
                NSString *orExpression = [self getOrExpression:genericName field:@"generico" logicConditionStarted:NO];
                
                [logicExpression appendString:orExpression];
            } else {
                NSString *andExpression = [self getAndExpression:genericName field:@"generico" logicConditionStarted:NO];
                
                [logicExpression appendString:andExpression];
            }
            
            [logicExpression appendString:@")"];
            [query appendString:logicExpression];
        } else {
            [query appendString:[self getLikeExpression:@"generico" value:genericName]];
        }
        
        conditionStarted = YES;
    }
    
    if(comercialName != nil && comercialName.length > 0) {
        if(conditionStarted) {
            [query appendString:@" AND "];
        } else {
            conditionStarted = YES;
        }
        
        [query appendString:[self getLikeExpression:@"comercial" value:comercialName]];
    }
    
    if(laboratory != nil && laboratory.length > 0) {
        if(conditionStarted) {
            [query appendString:@" AND "];
        } else {
            conditionStarted = YES;
        }
        
        [query appendString:[self getLikeExpression:@"laboratorio" value:laboratory]];
    }
    
    [query appendString:@" ORDER BY hospitalario ASC, precio ASC"];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    sqlite3 *database = [[DataBaseProvider instance] getDataBase];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Medicine *medicine = [self getMedicine:statement];
            
            [result addObject:medicine];
        }
        
        sqlite3_finalize(statement);
    }else {
        NSLog(@"Error while creating statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_close(database);
    
    return result;
}

- (NSArray *)getByGenericName:(NSString *)genericName {
    NSString *query = [NSString stringWithFormat: @"SELECT * FROM medicamentos WHERE generico=\"%@\" COLLATE NOCASE ORDER BY hospitalario ASC, precio ASC", genericName];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    sqlite3 *database = [[DataBaseProvider instance] getDataBase];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Medicine *medicine = [self getMedicine:statement];
            
            [result addObject:medicine];
        }
        
        sqlite3_finalize(statement);
    }else {
        NSLog(@"Error while creating statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_close(database);
    
    return result;
}

- (NSArray *)getByActiveComponent:(NSString *)componentName {
    NSMutableString *query = [[NSMutableString alloc] init];
    
    [query appendString:@"SELECT * FROM medicamentos WHERE generico LIKE ?001 COLLATE NOCASE ORDER BY hospitalario ASC, precio ASC"];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    sqlite3 *database = [[DataBaseProvider instance] getDataBase];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        NSString *componentNameSearch = [NSString stringWithFormat:@"%%%@%%", componentName];
        
        sqlite3_bind_text(statement, 1, [componentNameSearch UTF8String], -1, SQLITE_STATIC);
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Medicine *medicine = [self getMedicine:statement];
            
            [result addObject:medicine];
        }
        
        sqlite3_finalize(statement);
    }else {
        NSLog(@"Error while creating statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_close(database);
    
    return result;
}

- (NSArray *) getGenericNames:(NSString *)searchText {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    sqlite3 *database = [[DataBaseProvider instance] getDataBase];
    NSString *query = @"SELECT DISTINCT generico FROM medicamentos WHERE generico LIKE ?001 COLLATE NOCASE ORDER BY generico ASC";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        NSString *search = [NSString stringWithFormat:@"%%%@%%", searchText];
        
        sqlite3_bind_text(statement, 1, [search UTF8String], -1, SQLITE_STATIC);
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *genericNameChars = (char *) sqlite3_column_text(statement, 0);
            NSString *genericName = [[NSString alloc] initWithUTF8String:genericNameChars];
            
            [result addObject:genericName];
        }
        
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
    
    return result;
}

- (NSArray *) getComercialNames:(NSString *)searchText {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    sqlite3 *database = [[DataBaseProvider instance] getDataBase];
    NSString *query = @"SELECT DISTINCT comercial FROM medicamentos WHERE comercial LIKE ?001 COLLATE NOCASE ORDER BY comercial ASC";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        NSString *search = [NSString stringWithFormat:@"%%%@%%", searchText];
        
        sqlite3_bind_text(statement, 1, [search UTF8String], -1, SQLITE_STATIC);
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *comercialNameChars = (char *) sqlite3_column_text(statement, 0);
            NSString *comercialName = [[NSString alloc] initWithUTF8String:comercialNameChars];
            
            [result addObject:comercialName];
        }
        
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
    
    return result;
}

- (NSArray *) getLaboratories:(NSString *)searchText {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    sqlite3 *database = [[DataBaseProvider instance] getDataBase];
    NSString *query = @"SELECT DISTINCT laboratorio FROM medicamentos WHERE laboratorio LIKE ?001 COLLATE NOCASE ORDER BY laboratorio ASC";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        NSString *search = [NSString stringWithFormat:@"%%%@%%", searchText];
        
        sqlite3_bind_text(statement, 1, [search UTF8String], -1, SQLITE_STATIC);
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *laboratoryChars = (char *) sqlite3_column_text(statement, 0);
            NSString *laboratory = [[NSString alloc] initWithUTF8String:laboratoryChars];
            
            [result addObject:laboratory];
        }
        
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
    
    return result;
}

- (BOOL) containsOrExpression: (NSString *) text {
    return [text containsString:@"?"];
}

- (BOOL) containsAndExpression: (NSString *) text {
    return [text containsString:@"#"];
}

- (NSString *) getOrExpression: (NSString *) value field: (NSString *) field logicConditionStarted: (BOOL) logicConditionStarted {
    if(![self containsOrExpression:value]) {
        return @"";
    }
    
    BOOL orConditionStarted = logicConditionStarted;
    NSMutableString *orExpression = [[NSMutableString alloc] init];
    NSArray *orComponents = [value componentsSeparatedByString:@"?"];
    
    for (NSString *orComponent in orComponents) {
        if([self containsAndExpression:orComponent]) {
            NSString *andExpression = [self getAndExpression:orComponent field:field logicConditionStarted:orConditionStarted];
            
            [orExpression appendString:andExpression];
            
            if(!orConditionStarted) {
                orConditionStarted = YES;
            }
        } else {
            if(orConditionStarted) {
                [orExpression appendString:@" OR "];
            } else {
                orConditionStarted = YES;
            }
            
            [orExpression appendString:[self getLikeExpression:field value:orComponent]];
        }
    }
    
    return orExpression;
}

- (NSString *) getAndExpression: (NSString *) value field: (NSString *) field logicConditionStarted: (BOOL) logicConditionStarted {
    if(![self containsAndExpression:value]) {
        return @"";
    }
    
    BOOL andConditionStarted = logicConditionStarted;
    NSMutableString *andExpression = [[NSMutableString alloc] init];
    NSArray *andComponents = [value componentsSeparatedByString:@"#"];
    
    for (NSString *andComponent in andComponents) {
        if(andConditionStarted) {
            [andExpression appendString:@" AND "];
        } else {
            andConditionStarted = YES;
        }
        
        [andExpression appendString:[self getLikeExpression:field value:andComponent]];
    }
    
    return andExpression;
}

- (NSString *) getLikeExpression:(NSString *) field value: (NSString *) value {
    return [NSString stringWithFormat:@"%@ LIKE \"%%%@%%\" COLLATE NOCASE", field, [String trim:value]];
}

-(Medicine *) getMedicine:(sqlite3_stmt *) statement {
    char *idChars = (char *) sqlite3_column_text(statement, 0);
    char *certificateChars = (char *) sqlite3_column_text(statement, 1);
    char *cuitChars = (char *) sqlite3_column_text(statement, 2);
    char *laboratoryChars = (char *) sqlite3_column_text(statement, 3);
    char *gtinChars = (char *) sqlite3_column_text(statement, 4);
    char *troquelChars = (char *) sqlite3_column_text(statement, 5);
    char *comercialNameChars = (char *) sqlite3_column_text(statement, 6);
    char *formChars = (char *) sqlite3_column_text(statement, 7);
    char *genericNameChars = (char *) sqlite3_column_text(statement, 8);
    char *countryChars = (char *) sqlite3_column_text(statement, 9);
    char *requestConditionChars = (char *) sqlite3_column_text(statement, 10);
    char *trazabilityChars = (char *) sqlite3_column_text(statement, 11);
    char *presentationChars = (char *) sqlite3_column_text(statement, 12);
    char *priceChars = (char *) sqlite3_column_text(statement, 13);
    int hopsitalUsage = sqlite3_column_int(statement, 14);
    
    NSString *id = [self getUTF8:idChars];
    NSString *certificate =  [self getUTF8:certificateChars];
    NSString *cuit = [self getUTF8:cuitChars];
    NSString *laboratory =  [self getUTF8:laboratoryChars];
    NSString *gtin =  [self getUTF8:gtinChars];
    NSString *troquel = [self getUTF8:troquelChars];
    NSString *comercialName = [self getUTF8:comercialNameChars];
    NSString *form = [self getUTF8:formChars];
    NSString *genericName = [self getUTF8:genericNameChars];
    NSString *country = [self getUTF8:countryChars];
    NSString *requestCondition = [self getUTF8:requestConditionChars];
    NSString *trazability = [self getUTF8:trazabilityChars];
    NSString *presentation = [self getUTF8:presentationChars];
    NSString *price = [self getUTF8:priceChars];
    
    Medicine *medicine = [[Medicine alloc] init];
    
    medicine.id = [self getFormattedValue:id];
    medicine.certificate = [self getFormattedValue:certificate];
    medicine.cuit = [self getFormattedValue:cuit];
    medicine.laboratory = [self getFormattedValue:laboratory];
    medicine.gtin = [self getFormattedValue:gtin];
    medicine.troquel = [self getFormattedValue:troquel];
    medicine.comercialName = [self getFormattedValue:comercialName];
    medicine.form = [self getFormattedValue:form];
    medicine.genericName = [self getFormattedValue:genericName];
    medicine.country = [self getFormattedValue:country];
    medicine.requestCondition = [self getFormattedValue:requestCondition];
    medicine.trazability = [self getFormattedValue:trazability];
    medicine.presentation = [self getFormattedValue:presentation];
    medicine.price = [self getFormattedPrice:price];
    medicine.hospitalUsage = (NSInteger)hopsitalUsage;
    
    return medicine;
}

-(NSString *) getUTF8:(char *)value {
    if(value == nil) {
        return @"";
    }
    
    return [NSString stringWithUTF8String:value];
}

-(NSString *) getFormattedValue:(NSString *)value {
    if(value == nil || value.length == 0) {
        return @"-";
    } else {
        return value;
    }
}

-(NSString *) getFormattedPrice:(NSString *)value {
    if(value == nil || value.length == 0) {
        return @"$-";
    } else {
        double price = [value doubleValue];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        return [formatter stringFromNumber:[NSNumber numberWithDouble:price]];
    }
}

@end
