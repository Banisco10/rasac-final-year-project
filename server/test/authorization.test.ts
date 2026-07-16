import test from "node:test";
import assert from "node:assert/strict";
import { canAssignRole, hasActiveGradingWindow, hasAnyRole, isLecturerAssignedToStudent } from "../src/utils/authorization.js";

test("hasAnyRole returns true when user has an allowed role", () => {
  assert.equal(hasAnyRole(["STUDENT"], ["ADMINISTRATOR", "STUDENT"]), true);
});

test("hasAnyRole returns false when user lacks allowed roles", () => {
  assert.equal(hasAnyRole(["LECTURER"], ["STUDENT"]), false);
});

test("canAssignRole blocks conflicting assignments", async () => {
  const client = {
    query: async () => ({
      rows: [{ code: "ADMINISTRATOR" }],
      rowCount: 1
    })
  } as never;

  const allowed = await canAssignRole(1, "LECTURER", client);
  assert.equal(allowed, false);
});

test("canAssignRole allows same-role assignment when no conflict exists", async () => {
  const client = {
    query: async () => ({
      rows: [{ code: "STUDENT" }],
      rowCount: 1
    })
  } as never;

  const allowed = await canAssignRole(1, "STUDENT", client);
  assert.equal(allowed, true);
});

test("isLecturerAssignedToStudent respects lecturer-course-student relationship", async () => {
  const client = {
    query: async () => ({
      rows: [{}],
      rowCount: 1
    })
  } as never;

  const allowed = await isLecturerAssignedToStudent(10, 20, 30, client);
  assert.equal(allowed, true);
});

test("hasActiveGradingWindow returns false when no active period exists", async () => {
  const client = {
    query: async () => ({
      rows: [],
      rowCount: 0
    })
  } as never;

  const allowed = await hasActiveGradingWindow(30, client);
  assert.equal(allowed, false);
});
