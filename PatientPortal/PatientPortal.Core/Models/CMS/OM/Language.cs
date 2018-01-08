﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PatientPortal.Domain.Models.CMS
{
    public partial class Language
    {
        public byte Id { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
        public byte[] Icon {get; set;}

        public virtual ICollection<PostTran> PostTrans { get; set; }
    }
}