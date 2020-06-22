const cryptojs = require('crypto-js');
const jwt = require('jsonwebtoken');
const keySecret = "mducpt1t";

const hash = (text) => {
    return cryptojs.SHA256(text, keySecret).toString();
};

const verify = (text, hashed) => {
    return hashed === hash(text);
};

const getToken = (text) => {
    try {
        return jwt.sign({ text }, keySecret);
    } catch (error) {
        console.log(error);
    }
    
}

const verifyToken = (token, userId) => {
    try {
        let { text } = jwt.verify(token, keySecret);
        return userId == text;
    } catch (error) {
        return false;
    }
}

module.exports = {
    hash,
    verify,
    getToken,
    verifyToken
}