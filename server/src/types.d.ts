declare module 'cors' {
  import type { RequestHandler } from 'express';
  const cors: (...args: any[]) => RequestHandler;
  export default cors;
}

declare module 'pg' {
  export class Pool {
    constructor(config?: any);
    query(text: string, values?: any[]): Promise<{ rows: any[]; rowCount: number }>;
  }
  export const types: {
    setTypeParser: (oid: number, parser: (value: string) => unknown) => void;
  };
}

