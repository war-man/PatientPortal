﻿using PatientPortal.Domain.LogManager;
using PatientPortal.PatientServices.Models;
using PatientPortal.Provider.Common;
using PatientPortal.Utility.Application;
using System;
using System.Web;
using System.Web.Mvc;
using WebMarkupMin.AspNet4.Mvc;
using static PatientPortal.Utility.Application.ApplicationGenerator;

namespace PatientPortal.PatientServices.Controllers
{
    [Authorize]
    [AppHandleError]
    //[CompressContent]
    //[MinifyHtml]
    public class PHRController : Controller
    {
        // GET: PHR
        public ActionResult Index()
        {
            try
            {
                return View();
            }
            catch (HttpException ex)
            {
                Logger.LogError(ex);
                int statusCode = ex.GetHttpCode();
                if (statusCode == 401)
                {
                    TempData["Alert"] = ApplicationGenerator.RenderResult(FuntionType.Department, APIConstant.ACTION_ACCESS);
                    return new HttpUnauthorizedResult();
                }

                throw ex;
            }
        }
        public FileResult PDFViewer()
        {
            string fileName = "16019791_CDHA_1.pdf";
            fileName.Replace(",", "");

            // Force the pdf document to be displayed in the browser
            var cd = new System.Net.Mime.ContentDisposition
            {
                FileName = fileName,
                Inline = true,
            };
            Response.AppendHeader("Content-Disposition", cd.ToString());

            string path = AppDomain.CurrentDomain.BaseDirectory + "Assets/PHR/16019791/20170320/";
            return File(path + fileName, System.Net.Mime.MediaTypeNames.Application.Pdf);

        }
    }
}