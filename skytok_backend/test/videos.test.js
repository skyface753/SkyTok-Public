const { expect } = require('chai');
let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../server');
let should = chai.should();

process.env.MODE = "TEST";
process.env.PG_HOST = "localhost";
process.env.REDIS_HOST = "localhost";
process.env.MONGO_HOST = "localhost";

chai.use(chaiHttp);

var testToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSIsImlhdCI6MTY0NjI0Njk1OSwiZXhwIjoxNjQ4ODM4OTU5fQ.4_81XxmUJlum6HuD3qCAa6b46mcvjo7EhE2Dh12dRog";

describe('Videos', () => {
    
/*
  * Test the /GET route
  */
  describe('/POST /videos/forUser', () => {
      it('it should get own Videos', (done) => {
        chai.request(server)
            .post('/videos/forUser').set('content-type', 'application/x-www-form-urlencoded').set('authorization', testToken)
            .end((err, res) => {
                  res.should.have.status(200);
                  res.body.error.should.be.false;
              done();
            });
      });
  });
  describe('/POST /videos/proposals', () => {
    it('it should get own Videos', (done) => {
      chai.request(server)
          .post('/videos/proposals').set('content-type', 'application/x-www-form-urlencoded').set('authorization', testToken)
          .end((err, res) => {
                res.should.have.status(200);
                res.body.error.should.be.false;
            done();
          });
    });
});
describe('/POST /videos/liked', () => {
  it('it should get own Videos', (done) => {
    chai.request(server)
        .post('/videos/liked').set({'content-type': 'application/x-www-form-urlencoded', 'authorization': testToken})
        .send({video_id: '1'})
        .end((err, res) => {
          res.should.have.status(400)
          res.body.error.should.be.true;
          done();
        });
  });
});

});
