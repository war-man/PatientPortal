﻿using System.Web;
using System.Web.Optimization;

namespace PatientPortal.CMS
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            #region Bundle javascript
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"
                        ));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/app").Include(
                        "~/Scripts/main.js",
                        "~/Scripts/jquery.menu-aim.js",
                        "~/Scripts/moment.js",
                        "~/Scripts/moment-with-locales.js",
                        "~/Libs/BackToTop/fis_backtop.js",
                        "~/Libs/bootstrap-datetimepicker-master/build/js/bootstrap-datetimepicker.min.js",
                        "~/Scripts/style.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/respond.js"));
            #endregion

            #region Bundle css
            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/reset.css",
                      "~/Content/bootstrap.css",
                      "~/Content/site.css",
                      "~/Libs/BackToTop/fis_backtop.css",
                      "~/Libs/bootstrap-datetimepicker-master/build/css/bootstrap-datetimepicker.min.css",
                      "~/Content/font-awesome.min.css"));
                      
            bundles.Add(new StyleBundle("~/TreeView/css").Include(
                      "~/Libs/TreeView/treeview.css"));

            bundles.Add(new StyleBundle("~/Content/loginCss").Include(
                "~/Content/bootstrap.css",
                "~/Content/login.css",
                "~/Content/font-awesome.min.css",
                "~/Content/checkbox-radio-build.css"
                ));

            #endregion
        }
    }
}