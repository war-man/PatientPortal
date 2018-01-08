﻿using ProtoBuf;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PatientPortal.CMS.Models
{
    [ProtoContract]
    public class LinkBuildingViewModel
    {
        public LinkBuildingViewModel()
        {
            Title = Url = string.Empty;
            IsUsed = true;
        }

        [ProtoMember(1)]
        public short Id { get; set; }
        [ProtoMember(2)]
        [Display(Name = "Tiêu đề")]
        [Required(ErrorMessage = "Xin vui lòng nhập tiêu đề")]
        [Remote("CheckExist", "LinkBuilding", HttpMethod = "POST", AdditionalFields = "Id", ErrorMessage = "Tiêu đề đã tồn tại. Vui lòng chọn tiêu đề khác!!!")]
        public string Title { get; set; }
        [ProtoMember(3)]
        [Display(Name = "URL")]
        [Required(ErrorMessage = "Xin vui lòng nhập địa chỉ liên kết website")]
        public string Url { get; set; }
        [ProtoMember(4)]
        [Display(Name = "Hiển thị")]
        public bool IsUsed { get; set; }
    }
}