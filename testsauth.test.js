// tests/auth.test.js
const request = require('supertest');
const app = require('../src/app');
const User = require('../src/models/User');

describe('Auth Controller', () => {
  beforeEach(async () => {
    await User.deleteMany({});
  });

  test('should register a new user', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'password123',
        phone: '+1234567890',
        role: 'rider'
      })
      .expect(201);

    expect(response.body).toHaveProperty('message');
    expect(response.body).toHaveProperty('userId');
  });

  test('should not register with existing email', async () => {
    await User.create({
      email: 'test@example.com',
      password: 'password123',
      phone: '+1234567890',
      role: 'rider'
    });

    await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'password123',
        phone: '+1234567890',
        role: 'rider'
      })
      .expect(400);
  });
});