FROM node:20

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm install

# Copy source code and config files
COPY . .

# Build TypeScript to JavaScript
RUN npm run build

# Remove devDependencies to reduce image size (optional)
# RUN npm prune --production

EXPOSE 8000

# Set production environment
ENV NODE_ENV=production

# Run database initialization then start server
CMD ["sh", "-c", "node dist/init-db.js && node dist/index.js"]