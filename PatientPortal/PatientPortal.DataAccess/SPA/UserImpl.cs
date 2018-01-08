﻿using PatientPortal.DataAccess.Repo.SPA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PatientPortal.DataAccess.Repo.Wrapper;
using PatientPortal.Domain.LogManager;
using PatientPortal.Domain.Common;
using PatientPortal.Domain.Models.SPA;

namespace PatientPortal.DataAccess.SPA
{
    public class UserImpl : IUser
    {
        private readonly IAdapterPattern _adapterPattern;

        public UserImpl(IAdapterPattern adapterPattern)
        {
            this._adapterPattern = adapterPattern;
        }

        public async Task<User> Get(Dictionary<string, object> param)
        {
            try
            {
                return await _adapterPattern.SingleExecuteQuery<User>(param, "usp_spa_User", DataConfiguration.instanceCore);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                return null;
            }
        }

        public async Task<List<User>> GetUserHaveScheduleExamine(Dictionary<string, object> param)
        {
            try
            {
                var data = await _adapterPattern.ExecuteQuery<User>(param, "usp_spa_User_HasScheduleExamine", DataConfiguration.instanceCore);
                return data.ToList();
            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                return null;
            }
        }

        public async Task<List<User>> Query(Dictionary<string, object> param)
        {
            try
            {
                var data = await _adapterPattern.ExecuteQuery<User>(param, "usp_User", DataConfiguration.instanceCore);
                return data.ToList();
            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                return null;
            }
        }

        public async Task<Tuple<IEnumerable<UserProfile>, int>> GetDoctorList(Dictionary<string, dynamic> param)
        {
            try
            {
                Tuple<IEnumerable<UserProfile>, int> data = await _adapterPattern.ExecuteQueryOut<UserProfile>(param, "usp_spa_User", "totalItem", DataConfiguration.instanceCore);
                return data;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                return null;
            }
        }

        public async Task<UserProfile> GetUserProfile(Dictionary<string, object> param)
        {
            try
            {
                var data = await _adapterPattern.SingleExecuteQuery<UserProfile>(param, "usp_UserProfile", DataConfiguration.instanceCore);
                return data;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                return null;
            }
        }
    }
}