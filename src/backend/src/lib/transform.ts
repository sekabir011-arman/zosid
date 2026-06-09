export function toSnakeCase(key: string): string {
  return key.replace(/[A-Z]/g, (match) => `_${match.toLowerCase()}`);
}

export function toCamelCase(key: string): string {
  return key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
}

export function camelToSnake<T>(input: T): T {
  if (Array.isArray(input)) {
    return input.map((item) => camelToSnake(item)) as unknown as T;
  }

  if (input && typeof input === 'object' && !(input instanceof Date)) {
    return Object.entries(input).reduce((result, [key, value]) => {
      const newKey = toSnakeCase(key);
      return {
        ...result,
        [newKey]: camelToSnake(value),
      };
    }, {} as Record<string, unknown>) as T;
  }

  return input;
}

export function snakeToCamel<T>(input: T): T {
  if (Array.isArray(input)) {
    return input.map((item) => snakeToCamel(item)) as unknown as T;
  }

  if (input && typeof input === 'object' && !(input instanceof Date)) {
    return Object.entries(input).reduce((result, [key, value]) => {
      const newKey = toCamelCase(key);
      return {
        ...result,
        [newKey]: snakeToCamel(value),
      };
    }, {} as Record<string, unknown>) as T;
  }

  return input;
}
