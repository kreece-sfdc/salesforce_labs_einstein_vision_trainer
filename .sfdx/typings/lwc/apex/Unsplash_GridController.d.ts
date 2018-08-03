declare module "@salesforce/apex/Unsplash_GridController.TrainDataset" {
  export default function TrainDataset(param: {dataSetId: any}): Promise<any>;
}
declare module "@salesforce/apex/Unsplash_GridController.CreateDataset" {
  export default function CreateDataset(param: {dataSetId: any, name: any, labels: any, itemsString: any}): Promise<any>;
}
declare module "@salesforce/apex/Unsplash_GridController.GetDatasets" {
  export default function GetDatasets(param: {hasDataSetId: any}): Promise<any>;
}
declare module "@salesforce/apex/Unsplash_GridController.SearchUnsplash" {
  export default function SearchUnsplash(param: {query: any, page_number: any}): Promise<any>;
}
declare module "@salesforce/apex/Unsplash_GridController.ImageSelection" {
  export default function ImageSelection(param: {items: any}): Promise<any>;
}
declare module "@salesforce/apex/Unsplash_GridController.HasAccessToken" {
  export default function HasAccessToken(): Promise<any>;
}
declare module "@salesforce/apex/Unsplash_GridController.GetAuthUrl" {
  export default function GetAuthUrl(): Promise<any>;
}
declare module "@salesforce/apex/Unsplash_GridController.getSessionId" {
  export default function getSessionId(): Promise<any>;
}
