FROM node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8080

COPY --chown=node:node package.json ./
COPY --chown=node:node src/ ./src/

USER node
EXPOSE 8080

CMD ["node", "src/server.js"]
