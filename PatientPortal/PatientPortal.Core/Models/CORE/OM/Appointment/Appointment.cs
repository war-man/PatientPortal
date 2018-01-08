﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PatientPortal.Domain.Models.CORE
{
    public partial class Appointment
    {
        public int Id { get; set; }
        public string PhysicianId { get; set; }
        public string PatientId { get; set; }
        public string Symptom { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime ModifiedDate { get; set; }
    }
}