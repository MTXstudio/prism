export function SelectAll(tableName: string): string {
    return `SELECT * FROM ${tableName}`;
};

export function InsertOrUpdate(
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
): string {
    return `INSERT INTO ${tableId} as tk ( 
        projectId, 
        collectionId,
        supply,
        description,
        name,
        external_url,
        attributes,
        layers,
        image) 
    VALUES ('${tokenId}', '${projectId}', '${collectionId}', '${supply}', '${description}','${name}','${external_url}','${attributes}', ,'${layers}','${image}') 
    ON CONFLICT (tokenId) DO UPDATE SET description = '${description}' attibutes = ${attributes} layers = ${layers} image = ${image}
    WHERE tk.tokenId = '${tokenId}';`
}

export function CreateTokeMetadataTable(tokenName: string) {
    return `CREATE TABLE ${tokenName} (
        projectId int,
        collectionId int,
        supply int,
        description text,
        name text,
        external_url text,
        attributes text[],
        layers text[],
        image text)`;
}

