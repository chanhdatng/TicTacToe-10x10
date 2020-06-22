const express = require('express');
const route = express.Router();
const {hash} = require('./../lib/crypto');
const {exequery} = require('../menu');

route.post('/register',async (req, res) =>{
    try {
        let {Username, Password, Email, Fullname} = req.body;

        if(Username == '' || Username == undefined){
            return res.json({error: true, message: 'Tên đăng nhập không được thiếu!'});
        }

        if(Password == '' || Password == undefined){
            return res.json({error: true, message: 'Mật khẩu không được thiếu!'});
        }

        if(Email == '' || Email == undefined){
            return res.json({error: true, message: 'Email không được thiếu!'});
        }

        if(Fullname == '' || Fullname == undefined){
            return res.json({error: true, message: 'Tên không được thiếu!'});
        }

        let pwd = hash(Password);

        console.log({pwd});                

        let bindParams = [
            Username, pwd, Email, Fullname, 'ADD'
        ];

        let {result} = await exequery('USER', bindParams);

        if(result === undefined) {            
            return res.json({error: true, message: 'Đăng ký thất bại!'});
        }

        let {p_err_code,p_err_desc} = result.rows[0];
            
        if(p_err_code == 0) {            
            return res.json({error: false , message: 'Đăng ký thành công!'});
        }
        else {         
            return res.json({error: true , message: p_err_desc});
         }
        
    } catch (error) {
        return res.json({error: true, message: err.message});
    }
});

exports.USER_ROUTE = route;