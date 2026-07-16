const bcrypt = require('bcryptjs');
const password = 'YourNewPassword123!';
bcrypt.hash(password, 12).then(hash => console.log(hash));

