import { registerPlugin } from '@capacitor/core';
import { IZip, UnZipOptions, ZipOptions } from './definitions';

interface CapacitorZipPlugin {
    zip(options: ZipOptions, progress?: Function): Promise<any>;
    unZip(options: UnZipOptions, progress?: Function): Promise<any>;
}

const ZipPlugin = registerPlugin<CapacitorZipPlugin>('ZipPlugin');

export class Zip implements IZip {
    public zip(options: ZipOptions, progress?: Function): Promise<any> {
        return new Promise((resolve, reject) => {
            ZipPlugin.zip(options, (data: any, error: any) => {
                if (!error) {
                    if (!data.completed) {
                        if (progress) {
                            progress({
                                value: data.progress
                            });
                        }
                    } else {
                        resolve({
                            value: data.path
                        });
                    }
                } else {
                    reject(error);
                }
            });
        });
    }

    public unZip(options: UnZipOptions, progress?: Function): Promise<any> {
        return new Promise((resolve, reject) => {
            ZipPlugin.unZip(options, (data: any, error: any) => {
                if (!error) {
                    if (!data.completed) {
                        if (progress) {
                            progress({
                                value: data.progress
                            });
                        }
                    } else {
                        resolve({
                            value: data.path
                        });
                    }
                } else {
                    reject(error);
                }
            });
        });
    }
}
