 Stage 1: Build Stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install build tools
RUN apk add --no-cache python3 make g++
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production
FROM node:18-alpine AS runner

WORKDIR /app

# Add a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only necessary runtime files
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Use non-root user
USER appuser
# Set environment
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# Start the app
CMD ["node", "server.js"]