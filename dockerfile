# Stage 1: Development/Build Stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies
RUN apk add --no-cache python3 make g++

# Copy package files and install dependencies
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy files
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production Stage
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Create a non-root user and group, e.g. 'appuser'
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy necessary files from builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Change ownership to appuser
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set environment variables
ENV NODE_ENV=production

# Expose the port the app runs on
ENV PORT=3000

# Expose the port for the application
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]
