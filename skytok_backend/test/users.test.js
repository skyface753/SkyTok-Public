let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../server');
let should = chai.should();

process.env.MODE = "TEST";
process.env.PG_HOST = "localhost";
process.env.REDIS_HOST = "localhost";
process.env.MONGO_HOST = "localhost";

chai.use(chaiHttp);

describe('Users', () => {
    
/*
  * Test the /GET route
  */
  describe('/POST users/status', () => {
      it('it should check that user is logged in', (done) => {
        chai.request(server)
            .post('/users/status').set('content-type', 'application/x-www-form-urlencoded').set('authorization', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSIsImlhdCI6MTY0NjI0Njk1OSwiZXhwIjoxNjQ4ODM4OTU5fQ.4_81XxmUJlum6HuD3qCAa6b46mcvjo7EhE2Dh12dRog')
            .end((err, res) => {
                  res.should.have.status(200);
                  res.body.error.should.be.false;
              done();
            });
      });
  });
  describe('/POST users/login', () => {
    it('it should login user success', (done) => {
      chai.request(server)
          .post('/login').set('content-type', 'application/x-www-form-urlencoded')
          .send({usernameOrEmail: 'sjoerz', password: 'SkyTok'})
          .end((err, res) => {
            res.should.have.status(200);
            res.body.error.should.be.false;
            done();
          });
    });
  });
  describe('/POST users/login', () => {
    it('it should login user fail', (done) => {
      chai.request(server)
          .post('/login').set('content-type', 'application/x-www-form-urlencoded')
          .send({usernameOrEmail: 'sjoerz', password: 'WrongPass'})
          .end((err, res) => {
            res.should.have.status(400);
            res.body.error.should.be.true;
            done();
          });
    });
  });
});
