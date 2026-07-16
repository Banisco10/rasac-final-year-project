import { seedDemoData, store } from '../data/store.js';

seedDemoData();
console.log(JSON.stringify({
  users: store.users.length,
  courses: store.courses.length,
  enrollments: store.enrollments.length,
  periods: store.academicPeriods.length,
}));
