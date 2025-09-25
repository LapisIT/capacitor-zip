import { WebPlugin } from '@capacitor/core';
export class ZipPluginWeb extends WebPlugin {
    constructor() {
        super(); // no arguments in Capacitor 7
        // define readonly properties
        this.name = 'ZipPlugin';
        this.platforms = ['web'];
    }
    zip(options) {
        console.log(options);
        return Promise.resolve({});
    }
    unZip(options) {
        console.log(options);
        return Promise.resolve({});
    }
}
const ZipPlugin = new ZipPluginWeb();
export { ZipPlugin };
//# sourceMappingURL=web.js.map