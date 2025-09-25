import { WebPlugin } from '@capacitor/core';
import { IZip, ZipOptions, UnZipOptions } from './definitions';

export class ZipPluginWeb extends WebPlugin implements IZip {
  // define readonly properties
  readonly name = 'ZipPlugin';
  readonly platforms = ['web'];

  constructor() {
    super(); // no arguments in Capacitor 7
  }

  zip(options: ZipOptions): Promise<any> {
    console.log(options);
    return Promise.resolve({});
  }
  unZip(options: UnZipOptions): Promise<any> {
    console.log(options);
    return Promise.resolve({});
  }
}

const ZipPlugin = new ZipPluginWeb();

export { ZipPlugin };
