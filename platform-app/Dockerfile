FROM node:22-alpine

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8080

COPY --chown=node:node package.json ./
COPY --chown=node:node src/ ./src/

USER node
EXPOSE 8080

CMD ["node", "src/server.js"]
