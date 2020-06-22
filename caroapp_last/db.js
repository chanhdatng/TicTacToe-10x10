const sequelize = require('sequelize');

const db = new sequelize({
    database: "caroapp",
    username: "postgres",
    password: "kyo1122",
    host: "localhost",
    port: "5432",
    dialect: "postgres",
    dialectOptions: {
        ssl: false
    },
    define: {
        freezeTableName: true
    }
});

db.authenticate()
.then(() => console.log("Database successfully connected"))
.catch(err => console.log(err.message));

// const USER = db.define("USER", {
//     username: sequelize.STRING,
//     password: sequelize.STRING,
//     email: sequelize.STRING,
//     fullname: sequelize.STRING,
//     score: sequelize.INTEGER
// });


const USER = db.define("USER", {
    username: {
        primaryKey: true,
        type: sequelize.STRING
    },
    password: {
        allowNull: false,
        type: sequelize.STRING
    },
    email: {
        allowNull: false,
        type: sequelize.STRING
    },
    fullname: {
        allowNull: false,
        type: sequelize.STRING
    },
    score: {
        allowNull: false,
        type: sequelize.INTEGER
    }
})

module.exports = USER;

// module.exports = (db) => {
//     const USER = db.define("USER", {
//         username: {
//             primaryKey: true,
//             type: sequelize.STRING
//         },
//         password: {
//             allowNull: false,
//             type: sequelize.STRING
//         },
//         email: {
//             allowNull: false,
//             type: sequelize.STRING
//         },
//         fullname: {
//             allowNull: false,
//             type: sequelize.STRING
//         },
//         score: {
//             allowNull: false,
//             type: sequelize.INTEGER
//         }
//     })
// }

// create Table
// db.sync();

// insert 1 user
// USER.create({
//     username: "minhduc",
//     password: "duc123",
//     email: "minhduc@email.ac.vn",
//     fullname: "Võ Minh Đức",
//     score: 0
// }).then(USER => console.log(USER.get({plain: true})));

// insert more user
// USER.bulkCreate([
//     {
//         username: "minhduc",
//         password: "duc123",
//         email: "minhduc@email.ac.vn",
//         fullname: "Võ Minh Đức",
//         score: 0
//     },
//     {
//         username: "chanhdat",
//         password: "dat234",
//         email: "dat.nc@gmail.com",
//         fullname: "Nguyễn Chánh Đạt",
//         score: 0
//     },
//     {
//         username: "manhcuong",
//         password: "cuong789",
//         email: "manhcuongtk3@gmail.com",
//         fullname: "Phạm Hữu Cường",
//         score: 0
//     }
// ]).then((USER) => {
//     USER.forEach((user) => {
//         console.log(user.get({plain: true}))
//     })
// });

// destroy rows, Returns a number that is the number of rows deleted in the table
// USER.destroy({
//     where: {
//         id: 3
//     }
// }).then(row => console.log(row));

// update rows, Returns a number that is the number of rows updated in the table
// USER.update({
//     password: "cuong777"
// },{
//     where: {id: 2}
// })
// .then(row => console.log(row));

// findOne, No condition default first record
// USER.findOne({raw: true})
// .then(user => console.log(user));

// findOne, have condition
// USER.findOne({
//     raw: true,
//     where: {
//         id: 2
//     }
// })
// .then(user => console.log(user));

// findAll
// USER.findAll({raw: true})
// .then((arrusers) => {
//     arrusers.forEach((user) => {
//         console.log(user);
//     })
// });

// findByPk
// USER.findByPk(2, {raw: true})
// .then(user => console.log(user));