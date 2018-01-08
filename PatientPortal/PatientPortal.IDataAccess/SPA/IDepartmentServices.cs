﻿using PatientPortal.Domain.Models.SPA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PatientPortal.DataAccess.Repo.SPA
{
    public interface IDepartmentServices
    {
        Task<IEnumerable<DepartmentServices>> Query(Dictionary<string, dynamic> para);
    }
}