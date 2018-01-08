﻿using ProtoBuf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PatientPortal.API.SPA.ViewModels
{
    public class UserProfileViewModel
    {
        public string UserId { get; set; }
        public string TabCode { get; set; }
        public string Description { get; set; }
        public string Name { get; set; }
        public string Image { get; set; }
        public string UserName { get; set; }
    }
}