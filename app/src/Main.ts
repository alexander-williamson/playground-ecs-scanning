import Koa from "koa";
import Router from "koa-router";

import json from "koa-json";
import logger from "koa-logger";

const app = new Koa();
app.use(json());
app.use(logger());

const router = new Router();
router.get("/", async (ctx, next) => {
  ctx.body = { message: "Hello world" };
  await next();
});

app.use(router.routes()).use(router.allowedMethods());
app.listen(3000, () => {
  console.log("Koa started");
});

const a = 1;
console.debug(a);