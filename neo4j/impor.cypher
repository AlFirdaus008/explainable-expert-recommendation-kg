// Impor Knowledge Graph UNESA Infokom ke Neo4j
// Salin seluruh berkas CSV ke folder import milik database, lalu jalankan berkas ini.

// ---------- Indeks ----------
CREATE INDEX dosen_id  IF NOT EXISTS FOR (d:Dosen)  ON (d.id);
CREATE INDEX paper_id  IF NOT EXISTS FOR (p:Paper)  ON (p.id);
CREATE INDEX topik_id  IF NOT EXISTS FOR (t:Topik)  ON (t.id);
CREATE INDEX jurnal_id IF NOT EXISTS FOR (j:Jurnal) ON (j.id);
CREATE INDEX prodi_id  IF NOT EXISTS FOR (s:Prodi)  ON (s.id);

// ---------- Node ----------
LOAD CSV WITH HEADERS FROM 'file:///node_dosen.csv' AS baris
CREATE (:Dosen {id: baris.id, nama: baris.nama, prodi: baris.prodi, disiplin: baris.disiplin});

LOAD CSV WITH HEADERS FROM 'file:///node_paper.csv' AS baris
CREATE (:Paper {id: toInteger(baris.id), judul: baris.judul,
                tahun: toInteger(baris.tahun), jurnal: baris.jurnal,
                doi: baris.doi, sumber: baris.sumber});

LOAD CSV WITH HEADERS FROM 'file:///node_topik.csv' AS baris
CREATE (:Topik {id: baris.id, nama: baris.nama});

LOAD CSV WITH HEADERS FROM 'file:///node_jurnal.csv' AS baris
CREATE (:Jurnal {id: baris.id, nama: baris.nama});

LOAD CSV WITH HEADERS FROM 'file:///node_prodi.csv' AS baris
CREATE (:Prodi {id: baris.id, nama: baris.nama});

// ---------- Relasi ----------
LOAD CSV WITH HEADERS FROM 'file:///edge_writes.csv' AS baris
MATCH (d:Dosen {id: baris.dosen_id}), (p:Paper {id: toInteger(baris.paper_id)})
CREATE (d)-[:WRITES]->(p);

LOAD CSV WITH HEADERS FROM 'file:///edge_has_topic.csv' AS baris
MATCH (p:Paper {id: toInteger(baris.paper_id)}), (t:Topik {id: baris.topik_id})
CREATE (p)-[:HAS_TOPIC]->(t);

LOAD CSV WITH HEADERS FROM 'file:///edge_published_in.csv' AS baris
MATCH (p:Paper {id: toInteger(baris.paper_id)}), (j:Jurnal {id: baris.jurnal_id})
CREATE (p)-[:PUBLISHED_IN]->(j);

LOAD CSV WITH HEADERS FROM 'file:///edge_belongs_to.csv' AS baris
MATCH (d:Dosen {id: baris.dosen_id}), (s:Prodi {id: baris.prodi_id})
CREATE (d)-[:BELONGS_TO]->(s);

LOAD CSV WITH HEADERS FROM 'file:///edge_co_researches.csv' AS baris
MATCH (a:Prodi {id: baris.prodi_a}), (b:Prodi {id: baris.prodi_b})
CREATE (a)-[:CO_RESEARCHES]->(b);

// ---------- Contoh kueri ----------
// Siapa saja pakar topik tertentu, beserta jumlah papernya
// MATCH (d:Dosen)-[:WRITES]->(p:Paper)-[:HAS_TOPIC]->(t:Topik {id: 'machine learning'})
// RETURN d.nama, d.prodi, count(p) AS jumlah ORDER BY jumlah DESC LIMIT 10;

// Jalur penjelasan: kenapa seorang dosen relevan dengan sebuah topik
// MATCH jalur = (d:Dosen {nama: 'Aditya Prapanca, S.T., M.Kom.'})
//               -[:WRITES]->(:Paper)-[:HAS_TOPIC]->(t:Topik {id: 'machine learning'})
// RETURN jalur LIMIT 5;

// Pasangan prodi yang paling sering berkolaborasi
// MATCH (a:Prodi)<-[:BELONGS_TO]-(:Dosen)-[:WRITES]->(p:Paper)<-[:WRITES]-(:Dosen)-[:BELONGS_TO]->(b:Prodi)
// WHERE a.id < b.id
// RETURN a.nama, b.nama, count(DISTINCT p) AS jumlah ORDER BY jumlah DESC LIMIT 10;
