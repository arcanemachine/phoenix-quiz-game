import {
  data as baseData,
  directives as baseDirectives,
  stores as baseStores,
} from "js/base/alpine";

// export generic alpine types
export type AlpineComponent = any;
export type AlpineInstance = any;
export type AlpineStore = any;

export const data = [...baseData];
export const directives = [...baseDirectives];
export const stores = [...baseStores];
