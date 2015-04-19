﻿using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Anmat.Server.Core
{
    public class DocumentColumnMetadata
    {
        
        public int ColumnNumber { get; set; }

        public string Name { get; set; }

        public string Type { get; set; }

        public bool IsNullable { get; set; }

    }
}
