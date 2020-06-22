const bcrypt = require('bcryptjs');

// const hashPwd = (plainText) =>{
//     return new Promise(resolve =>{
//         let salt =  bcrypt.genSalt(10);
//         bcrypt.hash(plainText, salt, function(err, hashString) {
//             if(err) return resolve({ error: true, message: err.message});

//             resolve({error: false, data: hashString});
//         });
//     });
// }

let hashPwd = async (planText) =>{
    let saltRandom = await bcrypt.genSalt(10);
    let hashString = await bcrypt.hash(planText, saltRandom);
    return hashString;
}

let comparePwd = (planText,hashPwd) =>{
    return new Promise(resolve =>{
        bcrypt.compare(planText, hashPwd, (err, isMatch) =>{
            if(err) return res.json({err: true, message: err.message});

            if(!isMatch) return resolve({ err: true}); 
            
            return resolve({ err: false}); 
        });
    });
};

module.exports = {
    hashPwd, 
    comparePwd
}