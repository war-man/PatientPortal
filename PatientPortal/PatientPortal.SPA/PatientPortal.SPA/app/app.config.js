﻿'use strict';

angular.
module('spaApp')
    .config(['$routeProvider', '$locationProvider', '$logProvider', '$compileProvider','$ocLazyLoadProvider',
    function ($routeProvider, $locationProvider, $logProvider, $compileProvider, $ocLazyLoadProvider) {
    $logProvider.debugEnabled(true);
    $locationProvider.html5Mode(true).hashPrefix('!'); //the hashPrefix is for SEO
    $compileProvider.debugInfoEnabled(false);
    $routeProvider
        .when('/', {
            templateUrl: "app/components/home-page/home-page.template.html",
            controller: "HomePageController"
        })
        .when('/posts', {
            templateUrl: "app/components/posts/posts.template.html",
            controller: "PostsController"
        })
        .when('/posts/:id', {
            templateUrl: "app/components/posts/posts.template.html",
            controller: "PostsController"
        })
        .when('/post/:id', {
            templateUrl: "app/components/post-detail/post-detail.template.html",
            controller: "PostDetailController"
        })
        .when('/about/:id', {
            templateUrl: "app/components/about/about.template.html",
            controller: "AboutController"
        })
        .when('/appointment', {
            templateUrl: "app/components/appointment/appointment.template.html",
            controller: "AppointmentController"
        })
        .when('/contact', {
            templateUrl: "app/components/contact/contact.template.html",
            controller: "ContactController"
        })
        .when('/about', {
            templateUrl: "app/components/about/about.template.html",
            controller: "AboutController"
        })
        .when('/gallery', {
            templateUrl: "app/components/gallery/gallery.template.html",
            controller: "GalleryController"
        })
        .when('/doctors', {
            templateUrl: "app/components/doctors/doctors.template.html",
            controller: "DoctorsController"
        })
        .when('/department/:id', {
            templateUrl: "app/components/department/department.template.html",
            controller: "DepartmentController"
        })
        .otherwise('/');

    //$stateProvider
    //       .state("home", {
    //           url: "/",
    //           templateUrl: "app/components/home-page/home-page.template.html",
    //           controller: 'HomePageController',
    //           resolve: { // Any property in resolve should return a promise and is executed before the view is loaded
    //               loadMyCtrl: ['$ocLazyLoad', function ($ocLazyLoad) {
    //                   // you can lazy load files for an existing module
    //                   return $ocLazyLoad.load('app/components/home-page/home-page.controller.js');
    //               }]
    //           }
    //       })

    
}]);