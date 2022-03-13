export interface TableInserOrUpdateBody {
  tableId: string,
  tokenId: number,
  projectId: number,
  collectionId: number,
  supply: number,
  description: string,
  name: string,
  external_url: string,
  attributes: string[],
  layers: string[],
  image: string
}