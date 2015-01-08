unit uLibMongocAPI;

interface

uses
  Windows, SysUtils, LibBsonAPI, MongoBson, uMongoReadPrefs, uDelphi5;

const
  LibMongoc_Dll = LibBson_DLL;
  BSON_HOST_NAME_MAX = 255;

type
(*typedef struct
  {
    bool                        is_initialized;
    bool                        background;
    bool                        unique;
    const char                 *name;
    bool                        drop_dups;
    bool                        sparse;
    int32_t                     expire_after_seconds;
    int32_t                     v;
    const bson_t               *weights;
    const char                 *default_language;
    const char                 *language_override;
    mongoc_index_opt_geo_t     *geo_options;
    mongoc_index_opt_storage_t *storage_options;
    void                       *padding[6];
  } mongoc_index_opt_t; *)
  mongoc_index_opt_p = ^mongoc_index_opt_t;
  mongoc_index_opt_t = record
    is_initialized, background, unique: ByteBool;
    name: PAnsiChar;
    drop_dups, sparse: ByteBool;
    expire_after_seconds, v: LongInt;
    weights: bson_p;
    default_language, language_override: PAnsiChar;
    geo_options, storage_options: Pointer;
    padding: array[0..5] of Pointer;
  end;

(*struct _mongoc_host_list_t
  {
     mongoc_host_list_t *next;
     char                host [BSON_HOST_NAME_MAX + 1];
     char                host_and_port [BSON_HOST_NAME_MAX + 7];
     uint16_t            port;
     int                 family;
     void               *padding [4];
  }; *)
  mongoc_host_list_p = ^mongoc_host_list_t;
  mongoc_host_list_t = record
    next: mongoc_host_list_p;
    host: array[0..BSON_HOST_NAME_MAX] of AnsiChar;
    host_and_port: array[0..BSON_HOST_NAME_MAX + 6] of AnsiChar;
    port: Word;
    family: Integer;
    padding: array[0..3] of Pointer;
  end;

(*struct _mongoc_gridfs_file_opt_t
{
   const char   *md5;
   const char   *filename;
   const char   *content_type;
   const bson_t *aliases;
   const bson_t *metadata;
   uint32_t      chunk_size;
}; *)
  mongoc_gridfs_file_opt_p = ^mongoc_gridfs_file_opt_t;
  mongoc_gridfs_file_opt_t = record
    md5, filename, content_type: PAnsiChar;
    aliases, metadata: bson_p;
    chunk_size: LongWord;
  end;

  size_t = {$IFDEF WIN64}UInt64{$ELSE}LongWord{$ENDIF};
  ssize_t = {$IFDEF WIN64}Int64{$ELSE}LongInt{$ENDIF};
(*typedef struct
{
   size_t  iov_len;
   char   *iov_base;
} mongoc_iovec_t; *)
  mongoc_iovec_p = ^mongoc_iovec_t;
  mongoc_iovec_t = record
    iov_len: size_t;
    iov_base: PByte;
  end;


{ void mongoc_init (void); }
  procedure mongoc_init;
  cdecl; external LibMongoc_Dll;

{ void mongoc_cleanup (void); }
  procedure mongoc_cleanup;
  cdecl; external LibMongoc_Dll;


//
// mongoc_read_prefs_t
//


{ mongoc_read_prefs_t *
  mongoc_read_prefs_new (mongoc_read_mode_t read_mode); }
  function mongoc_read_prefs_new(read_mode: TMongoReadMode): Pointer;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_read_prefs_destroy (mongoc_read_prefs_t *read_prefs); }
  procedure mongoc_read_prefs_destroy(read_prefs: Pointer);
  cdecl; external LibMongoc_Dll;

{ mongoc_read_prefs_t *
  mongoc_read_prefs_copy (const mongoc_read_prefs_t *read_prefs); }
  function mongoc_read_prefs_copy(const read_prefs: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_read_prefs_is_valid (const mongoc_read_prefs_t *read_prefs); }
  function mongoc_read_prefs_is_valid(const read_prefs: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_read_prefs_add_tag (mongoc_read_prefs_t *read_prefs,
                             const bson_t        *tag); }
  procedure mongoc_read_prefs_add_tag(read_prefs: Pointer;
                                      const tag: bson_p);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_read_prefs_set_mode (mongoc_read_prefs_t *read_prefs,
                              mongoc_read_mode_t   mode); }
  procedure mongoc_read_prefs_set_mode(read_prefs: Pointer;
                                       mode: TMongoReadMode);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_read_prefs_set_tags (mongoc_read_prefs_t *read_prefs,
                              const bson_t        *tags); }
  procedure mongoc_read_prefs_set_tags(read_prefs: Pointer;
                                       const tags: bson_p);
  cdecl; external LibMongoc_Dll;

{ mongoc_read_mode_t
  mongoc_read_prefs_get_mode (const mongoc_read_prefs_t *read_prefs); }
  function mongoc_read_prefs_get_mode(const read_prefs: Pointer): TMongoReadMode;
  cdecl; external LibMongoc_Dll;

{ const bson_t *
  mongoc_read_prefs_get_tags (const mongoc_read_prefs_t *read_prefs); }
  function mongoc_read_prefs_get_tags(const read_prefs: Pointer): bson_p;
  cdecl; external LibMongoc_Dll;


//
// mongoc_client_t
//


{ mongoc_client_t *
  mongoc_client_new (const char *uri_string); }
  function mongoc_client_new(const uri_string: PAnsiChar): Pointer;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_client_destroy (mongoc_client_t *client); }
  procedure mongoc_client_destroy(client: Pointer);
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_client_command_simple (mongoc_client_t           *client,
                                const char                *db_name,
                                const bson_t              *command,
                                const mongoc_read_prefs_t *read_prefs,
                                bson_t                    *reply,
                                bson_error_t              *error); }
  function mongoc_client_command_simple(client: Pointer;
                                        const db_name: PAnsiChar;
                                        const command: bson_p;
                                        const read_prefs: Pointer;
                                        reply: bson_p;
                                        error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ char **
  mongoc_client_get_database_names (mongoc_client_t *client,
                                    bson_error_t    *error); }
  function mongoc_client_get_database_names(client: Pointer;
                                            error: bson_error_p): PPAnsiChar;
  cdecl; external LibMongoc_Dll;

{ int32_t
  mongoc_client_get_max_bson_size (mongoc_client_t *client); }
  function mongoc_client_get_max_bson_size(client: Pointer): LongInt;
  cdecl; external LibMongoc_Dll;

{ int32_t
  mongoc_client_get_max_message_size  (mongoc_client_t *client); }
  function mongoc_client_get_max_message_size(client: Pointer): LongInt;
  cdecl; external LibMongoc_Dll;

{ const mongoc_read_prefs_t *
  mongoc_client_get_read_prefs (const mongoc_client_t *client); }
  function mongoc_client_get_read_prefs(const client: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_client_get_server_status (mongoc_client_t     *client,
                                   mongoc_read_prefs_t *read_prefs,
                                   bson_t              *reply,
                                   bson_error_t        *error); }
  function mongoc_client_get_server_status(client: Pointer;
                                           read_prefs: Pointer;
                                           reply: bson_p;
                                           error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_client_set_read_prefs (mongoc_client_t           *client,
                                const mongoc_read_prefs_t *read_prefs); }
  procedure mongoc_client_set_read_prefs(client: Pointer;
                                         const read_prefs: Pointer);
  cdecl; external LibMongoc_Dll;

{ const mongoc_write_concern_t *
  mongoc_client_get_write_concern (const mongoc_client_t *client); }
  function mongoc_client_get_write_concern(const client: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_client_set_write_concern (mongoc_client_t              *client,
                                   const mongoc_write_concern_t *write_concern); }
  procedure mongoc_client_set_write_concern(client: Pointer;
                                            const write_concern: Pointer);
  cdecl; external LibMongoc_Dll;

{ mongoc_database_t *
  mongoc_client_get_database (mongoc_client_t *client,
                              const char      *name); }
  function mongoc_client_get_database(client: Pointer;
                                      const name: PAnsiChar): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_collection_t *
  mongoc_client_get_collection (mongoc_client_t *client,
                                const char      *db,
                                const char      *collection); }
  function mongoc_client_get_collection(client: Pointer;
                                        const db, collection: PAnsiChar): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_gridfs_t *
  mongoc_client_get_gridfs (mongoc_client_t *client,
                            const char      *db,
                            const char      *prefix,
                            bson_error_t    *error); }
  function mongoc_client_get_gridfs(client: Pointer;
                                    const db, prefix: PAnsiChar;
                                    error: bson_error_p): Pointer;
  cdecl; external LibMongoc_Dll;


//
// mongoc_write_concern_t
//


{ mongoc_write_concern_t *
  mongoc_write_concern_new (void); }
  function mongoc_write_concern_new: Pointer;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_write_concern_destroy (mongoc_write_concern_t *write_concern); }
  procedure mongoc_write_concern_destroy(write_concern: Pointer);
  cdecl; external LibMongoc_Dll;

{ mongoc_write_concern_t *
  mongoc_write_concern_copy (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_copy(const write_concern: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_write_concern_get_fsync (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_fsync(const write_concern: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_write_concern_get_journal (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_journal(const write_concern: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ int32_t
  mongoc_write_concern_get_w (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_w(const write_concern: Pointer): LongInt;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_write_concern_get_wmajority (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_wmajority(const write_concern: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ const char *
  mongoc_write_concern_get_wtag (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_wtag(const write_concern: Pointer): PAnsiChar;
  cdecl; external LibMongoc_Dll;

{ int32_t
  mongoc_write_concern_get_wtimeout (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_wtimeout(const write_concern: Pointer): LongInt;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_write_concern_set_fsync (mongoc_write_concern_t *write_concern,
                                  bool                    fsync_); }
  procedure mongoc_write_concern_set_fsync(write_concern: Pointer;
                                           fsync_: ByteBool);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_write_concern_set_journal (mongoc_write_concern_t *write_concern,
                                    bool                    journal); }
  procedure mongoc_write_concern_set_journal(write_concern: Pointer;
                                             journal: ByteBool);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_write_concern_set_w (mongoc_write_concern_t *write_concern,
                              int32_t                 w); }
  procedure mongoc_write_concern_set_w(write_concern: Pointer;
                                       w: Longint);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_write_concern_set_wmajority (mongoc_write_concern_t *write_concern,
                                      int32_t                 wtimeout_msec); }
  procedure mongoc_write_concern_set_wmajority(write_concern: Pointer;
                                               wtimeout_msec: Longint);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_write_concern_set_wtag (mongoc_write_concern_t *write_concern,
                                 const char             *tag); }
  procedure mongoc_write_concern_set_wtag(write_concern: Pointer;
                                          const tag: PAnsiChar);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_write_concern_set_wtimeout (mongoc_write_concern_t *write_concern,
                                     int32_t                 wtimeout_msec); }
  procedure mongoc_write_concern_set_wtimeout(write_concern: Pointer;
                                              wtimeout_msec: Longint);
  cdecl; external LibMongoc_Dll;


//
// mongoc_database_t
//


{ void
  mongoc_database_destroy (mongoc_database_t *database); }
  procedure mongoc_database_destroy(database: Pointer);
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_database_drop (mongoc_database_t *database,
                        bson_error_t      *error); }
  function mongoc_database_drop(database: Pointer; error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_database_add_user (mongoc_database_t *database,
                            const char        *username,
                            const char        *password,
                            const bson_t      *roles,
                            const bson_t      *custom_data,
                            bson_error_t      *error); }
  function mongoc_database_add_user(database: Pointer;
                                    const username, password: PAnsiChar;
                                    const roles, custom_data: bson_p;
                                    error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_database_remove_all_users (mongoc_database_t *database,
                                    bson_error_t      *error); }
  function mongoc_database_remove_all_users(database: Pointer;
                                            error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_database_command_simple (mongoc_database_t         *database,
                                  const bson_t              *command,
                                  const mongoc_read_prefs_t *read_prefs,
                                  bson_t                    *reply,
                                  bson_error_t              *error); }
  function mongoc_database_command_simple(database: Pointer;
                                          const command: bson_p;
                                          const read_prefs: Pointer;
                                          reply: bson_p;
                                          error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ mongoc_cursor_t *
  mongoc_database_command (mongoc_database_t         *database,
                           mongoc_query_flags_t       flags,
                           uint32_t                   skip,
                           uint32_t                   limit,
                           uint32_t                   batch_size,
                           const bson_t              *command,
                           const bson_t              *fields,
                           const mongoc_read_prefs_t *read_prefs); }
  function mongoc_database_command(database: Pointer;
                                   flags: Integer;
                                   skip, limit, batch_size: LongWord;
                                   const command, fields: bson_p;
                                   const read_prefs: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ char **
  mongoc_database_get_collection_names (mongoc_database_t *database,
                                        bson_error_t      *error); }
  function mongoc_database_get_collection_names(database: Pointer;
                                                error: bson_error_p): PPAnsiChar;
  cdecl; external LibMongoc_Dll;

{ const char *
  mongoc_database_get_name (mongoc_database_t *database); }
  function mongoc_database_get_name(database: Pointer): PAnsiChar;
  cdecl; external LibMongoc_Dll;

{ const mongoc_read_prefs_t *
  mongoc_database_get_read_prefs (const mongoc_database_t *database); }
  function mongoc_database_get_read_prefs(const database: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ const mongoc_write_concern_t *
  mongoc_database_get_write_concern (const mongoc_database_t *database); }
  function mongoc_database_get_write_concern(const database: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_database_has_collection (mongoc_database_t *database,
                                  const char        *name,
                                  bson_error_t      *error); }
  function mongoc_database_has_collection(database: Pointer;
                                          const name: PAnsiChar;
                                          error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_database_remove_user (mongoc_database_t *database,
                               const char        *username,
                               bson_error_t      *error); }
  function mongoc_database_remove_user(database: Pointer;
                                       const username: PAnsiChar;
                                       error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_database_set_read_prefs (mongoc_database_t         *database,
                                  const mongoc_read_prefs_t *read_prefs); }
  procedure mongoc_database_set_read_prefs(database: Pointer;
                                           const read_prefs: Pointer);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_database_set_write_concern  (mongoc_database_t            *database,
                                      const mongoc_write_concern_t *write_concern); }
  procedure mongoc_database_set_write_concern(database: Pointer;
                                              const write_concern: Pointer);
  cdecl; external LibMongoc_Dll;

{ mongoc_collection_t *
  mongoc_database_get_collection (mongoc_database_t *database,
                                  const char        *name); }
  function mongoc_database_get_collection(database: Pointer;
                                          const name: PAnsiChar): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_collection_t *
  mongoc_database_create_collection (mongoc_database_t *database,
                                     const char        *name,
                                     const bson_t      *options,
                                     bson_error_t      *error);  }
  function mongoc_database_create_collection(database: Pointer;
                                             const name: PAnsiChar;
                                             const options: bson_p;
                                             error: bson_error_p): Pointer;
  cdecl; external LibMongoc_Dll;


//
// mongoc_collection_t
//


{ void
  mongoc_collection_destroy (mongoc_collection_t *collection); }
  procedure mongoc_collection_destroy(collection: Pointer);
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_command_simple (mongoc_collection_t       *collection,
                                    const bson_t              *command,
                                    const mongoc_read_prefs_t *read_prefs,
                                    bson_t                    *reply,
                                    bson_error_t              *error); }
  function mongoc_collection_command_simple(collection: Pointer;
                                            const command: bson_p;
                                            const read_prefs: Pointer;
                                            reply: bson_p;
                                            error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ mongoc_cursor_t *
  mongoc_collection_command (mongoc_collection_t       *collection,
                             mongoc_query_flags_t       flags,
                             uint32_t                   skip,
                             uint32_t                   limit,
                             uint32_t                   batch_size,
                             const bson_t              *command,
                             const bson_t              *fields,
                             const mongoc_read_prefs_t *read_prefs)
  mongoc_collection_command; }
  function mongoc_collection_command(collection: Pointer;
                                     flags: Integer;
                                     skip, limit, batch_size: LongWord;
                                     const command, fields: bson_p;
                                     const read_prefs: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_cursor_t *
  mongoc_collection_aggregate (mongoc_collection_t       *collection,
                               mongoc_query_flags_t       flags,
                               const bson_t              *pipeline,
                               const bson_t              *options,
                               const mongoc_read_prefs_t *read_prefs)
     BSON_GNUC_WARN_UNUSED_RESULT; }
 function mongoc_collection_aggregate(collection: Pointer;
                                      flags: Integer;
                                      const pipeline, options: bson_p;
                                      const read_prefs: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_cursor_t *
  mongoc_collection_find (mongoc_collection_t       *collection,
                          mongoc_query_flags_t       flags,
                          uint32_t                   skip,
                          uint32_t                   limit,
                          uint32_t                   batch_size,
                          const bson_t              *query,
                          const bson_t              *fields,
                          const mongoc_read_prefs_t *read_prefs)
     BSON_GNUC_WARN_UNUSED_RESULT; }
  function mongoc_collection_find(collection: Pointer;
                                  flags: Integer;
                                  skip, limit, batch_size: LongWord;
                                  const query, fields: bson_p;
                                  const read_prefs: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ int64_t
  mongoc_collection_count (mongoc_collection_t       *collection,
                           mongoc_query_flags_t       flags,
                           const bson_t              *query,
                           int64_t                    skip,
                           int64_t                    limit,
                           const mongoc_read_prefs_t *read_prefs,
                           bson_error_t              *error); }
  function mongoc_collection_count(collection: Pointer;
                                   flags: Integer;
                                   const query: bson_p;
                                   skip, limit: Int64;
                                   const read_prefs: Pointer;
                                   error: bson_error_p): Int64;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_create_index (mongoc_collection_t      *collection,
                                  const bson_t             *keys,
                                  const mongoc_index_opt_t *opt,
                                  bson_error_t             *error); }
  function mongoc_collection_create_index(collection: Pointer;
                                          const keys: bson_p;
                                          const opt: mongoc_index_opt_p;
                                          error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_drop (mongoc_collection_t *collection,
                          bson_error_t        *error); }
  function mongoc_collection_drop(collection: Pointer;
                                  error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_drop_index (mongoc_collection_t *collection,
                                const char          *index_name,
                                bson_error_t        *error); }
  function mongoc_collection_drop_index(collection: Pointer;
                                        const index_name: PAnsiChar;
                                        error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_find_and_modify (mongoc_collection_t *collection,
                                     const bson_t        *query,
                                     const bson_t        *sort,
                                     const bson_t        *update,
                                     const bson_t        *fields,
                                     bool                 _remove,
                                     bool                 upsert,
                                     bool                 _new,
                                     bson_t              *reply,
                                     bson_error_t        *error); }
  function mongoc_collection_find_and_modify(collection: Pointer;
                                             const query, sort, update, fields: bson_p;
                                             _remove, upsert, _new: ByteBool;
                                             reply: bson_p;
                                             error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ const bson_t *
  mongoc_collection_get_last_error (const mongoc_collection_t *collection); }
  function mongoc_collection_get_last_error(const collection: Pointer): bson_p;
  cdecl; external LibMongoc_Dll;


{ const char *
  mongoc_collection_get_name (mongoc_collection_t *collection); }
  function mongoc_collection_get_name(collection: Pointer): PAnsiChar;
  cdecl; external LibMongoc_Dll;

{ const mongoc_read_prefs_t *
  mongoc_collection_get_read_prefs (const mongoc_collection_t *collection); }
  function mongoc_collection_get_read_prefs(const collection: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ const mongoc_write_concern_t *
  mongoc_collection_get_write_concern (const mongoc_collection_t *collection); }
  function mongoc_collection_get_write_concern(const collection: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_collection_set_read_prefs (mongoc_collection_t       *collection,
                                    const mongoc_read_prefs_t *read_prefs); }
  procedure mongoc_collection_set_read_prefs(collection: Pointer;
                                             const read_prefs: Pointer);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_collection_set_write_concern (mongoc_collection_t          *collection,
                                       const mongoc_write_concern_t *write_concern); }
  procedure mongoc_collection_set_write_concern(collection: Pointer;
                                                const write_concern: Pointer);
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_insert (mongoc_collection_t          *collection,
                            mongoc_insert_flags_t         flags,
                            const bson_t                 *document,
                            const mongoc_write_concern_t *write_concern,
                            bson_error_t                 *error); }
  function mongoc_collection_insert(collection: Pointer;
                                    flags: Integer;
                                    const document: bson_p;
                                    const write_concern: Pointer;
                                    error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_remove (mongoc_collection_t          *collection,
                            mongoc_remove_flags_t         flags,
                            const bson_t                 *selector,
                            const mongoc_write_concern_t *write_concern,
                            bson_error_t                 *error); }
  function mongoc_collection_remove(collection: Pointer;
                                    flags: Integer;
                                    const selector: bson_p;
                                    const write_concern: Pointer;
                                    error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_rename (mongoc_collection_t *collection,
                            const char          *new_db,
                            const char          *new_name,
                            bool                 drop_target_before_rename,
                            bson_error_t        *error); }
  function mongoc_collection_rename(collection: Pointer;
                                    const new_db, new_name: PAnsiChar;
                                    drop_target_before_rename: ByteBool;
                                    error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_save (mongoc_collection_t          *collection,
                          const bson_t                 *document,
                          const mongoc_write_concern_t *write_concern,
                          bson_error_t                 *error); }
  function mongoc_collection_save(collection: Pointer;
                                  const document: bson_p;
                                  const write_concern: Pointer;
                                  error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_stats (mongoc_collection_t *collection,
                           const bson_t        *options,
                           bson_t              *reply,
                           bson_error_t        *error); }
  function mongoc_collection_stats(collection: Pointer;
                                  const options: bson_p;
                                  reply: bson_p;
                                  error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_update (mongoc_collection_t          *collection,
                            mongoc_update_flags_t         flags,
                            const bson_t                 *selector,
                            const bson_t                 *update,
                            const mongoc_write_concern_t *write_concern,
                            bson_error_t                 *error); }
  function mongoc_collection_update(collection: Pointer;
                                    flags: Integer;
                                    const selector, update: bson_p;
                                    const write_concern: Pointer;
                                    error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_collection_validate (mongoc_collection_t *collection,
                              const bson_t        *options,
                              bson_t              *reply,
                              bson_error_t        *error); }
  function mongoc_collection_validate(collection: Pointer;
                                      const options: bson_p;
                                      reply: bson_p;
                                      error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;


//
// mongoc_index_opt_t
//


{ const mongoc_index_opt_t *
  mongoc_index_opt_get_default (void) BSON_GNUC_CONST; }
  function mongoc_index_opt_get_default: mongoc_index_opt_p;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_index_opt_init (mongoc_index_opt_t *opt); }
  procedure mongoc_index_opt_init(opt: mongoc_index_opt_p);
  cdecl; external LibMongoc_Dll;


//
// mongoc_cursor_t
//


{ void
  mongoc_cursor_destroy (mongoc_cursor_t *cursor); }
  procedure mongoc_cursor_destroy(cursor: Pointer);
  cdecl; external LibMongoc_Dll;

{ mongoc_cursor_t *
  mongoc_cursor_clone (const mongoc_cursor_t *cursor) BSON_GNUC_WARN_UNUSED_RESULT; }
  function mongoc_cursor_clone(const cursor: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ const bson_t *
  mongoc_cursor_current (const mongoc_cursor_t *cursor); }
  function mongoc_cursor_current(const cursor: Pointer): bson_p;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_cursor_error (mongoc_cursor_t *cursor,
                       bson_error_t    *error); }
  function mongoc_cursor_error(cursor: Pointer; error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_cursor_get_host (mongoc_cursor_t    *cursor,
                          mongoc_host_list_t *host); }
  procedure mongoc_cursor_get_host(cursor: Pointer; host: mongoc_host_list_p);
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_cursor_is_alive (const mongoc_cursor_t *cursor); }
  function mongoc_cursor_is_alive(const cursor: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_cursor_more (mongoc_cursor_t *cursor); }
  function mongoc_cursor_more(cursor: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_cursor_next (mongoc_cursor_t *cursor,
                      const bson_t   **bson); }
  function mongoc_cursor_next(cursor: Pointer; const bson: bson_pp): ByteBool;
  cdecl; external LibMongoc_Dll;


//
// mongoc_gridfs_t
//


{ void
  mongoc_gridfs_destroy (mongoc_gridfs_t *gridfs); }
  procedure mongoc_gridfs_destroy(gridfs: Pointer);
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_drop (mongoc_gridfs_t *gridfs,
                      bson_error_t    *error); }
  function mongoc_gridfs_drop(gridfs: Pointer; error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ mongoc_gridfs_file_t *
  mongoc_gridfs_create_file (mongoc_gridfs_t          *gridfs,
                             mongoc_gridfs_file_opt_t *opt); }
  function mongoc_gridfs_create_file(gridfs: Pointer;
                                     opt: mongoc_gridfs_file_opt_p): Pointer;
  cdecl; external LibMongoc_Dll;

 { mongoc_gridfs_file_list_t *
   mongoc_gridfs_find (mongoc_gridfs_t *gridfs,
                      const bson_t    *query); }
  function mongoc_gridfs_find(gridfs: Pointer; const query: bson_p): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_gridfs_file_t *
  mongoc_gridfs_find_one (mongoc_gridfs_t *gridfs,
                          const bson_t    *query,
                          bson_error_t    *error); }
  function mongoc_gridfs_find_one(gridfs: Pointer; const query: bson_p;
                                  error: bson_error_p): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_gridfs_file_t *
  mongoc_gridfs_find_one_by_filename (mongoc_gridfs_t *gridfs,
                                      const char      *filename,
                                      bson_error_t    *error); }
  function mongoc_gridfs_find_one_by_filename(gridfs: Pointer;
                                              filename: PAnsiChar;
                                              error: bson_error_p): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_collection_t *
  mongoc_gridfs_get_files (mongoc_gridfs_t *gridfs); }
  function mongoc_gridfs_get_files(gridfs: Pointer): Pointer;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_remove_by_filename (mongoc_gridfs_t *gridfs,
                                    const char      *filename,
                                    bson_error_t    *error); }
  function mongoc_gridfs_remove_by_filename(gridfs: Pointer;
                                            const filename: PAnsiChar;
                                            error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;


//
// mongoc_gridfs_cnv_file_t
//


{ mongoc_gridfs_file_t *
  mongoc_gridfs_create_cnv_file (mongoc_gridfs_t                *gridfs,
                                 mongoc_gridfs_file_opt_t       *opt,
                                 mongoc_gridfs_cnv_file_flags_t  flags); }
  function mongoc_gridfs_create_cnv_file(gridfs: Pointer;
                                         opt: mongoc_gridfs_file_opt_p;
                                         flags: Integer): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_gridfs_file_t *
  mongoc_gridfs_find_one_cnv (mongoc_gridfs_t *gridfs,
                              const bson_t    *query,
                              bson_error_t    *error,
                              mongoc_gridfs_cnv_file_flags_t  flags); }
  function mongoc_gridfs_find_one_cnv(gridfs: Pointer; const query: bson_p;
                                      error: bson_error_p;
                                      flags: Integer): Pointer;
  cdecl; external LibMongoc_Dll;

{ mongoc_gridfs_file_t *
  mongoc_gridfs_find_one_cnv_by_filename (mongoc_gridfs_t *gridfs,
                                          const char      *filename,
                                          bson_error_t    *error,
                                          mongoc_gridfs_cnv_file_flags_t  flags); }
  function mongoc_gridfs_find_one_cnv_by_filename(gridfs: Pointer;
                                                  filename: PAnsiChar;
                                                  error: bson_error_p;
                                                  flags: Integer): Pointer;
  cdecl; external LibMongoc_Dll;


{ void
  mongoc_gridfs_cnv_file_destroy (mongoc_gridfs_file_t *file); }
  procedure mongoc_gridfs_cnv_file_destroy(afile: Pointer);
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_cnv_file_save (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_save(afile: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_cnv_file_error (mongoc_gridfs_file_t *file,
                                bson_error_t         *error); }
  function mongoc_gridfs_cnv_file_error(afile: Pointer;
                                        error: bson_error_p): ByteBool;
  cdecl; external LibMongoc_Dll;

{ ssize_t
  mongoc_gridfs_cnv_file_writev (mongoc_gridfs_file_t *file,
                                 mongoc_iovec_t       *iov,
                                 size_t                iovcnt,
                                 uint32_t              timeout_msec); }
  function mongoc_gridfs_cnv_file_writev(afile: Pointer;
                                         iov: mongoc_iovec_p;
                                         iovcnt: size_t;
                                         timeout_msec: LongWord): ssize_t;
  cdecl; external LibMongoc_Dll;

{ ssize_t
  mongoc_gridfs_cnv_file_readv (mongoc_gridfs_file_t *file,
                                mongoc_iovec_t       *iov,
                                size_t                iovcnt,
                                size_t                min_bytes,
                                uint32_t              timeout_msec); }
  function mongoc_gridfs_cnv_file_readv(afile: Pointer;
                                        iov: mongoc_iovec_p;
                                        iovcnt, min_bytes: size_t;
                                        timeout_msec: LongWord): ssize_t;
  cdecl; external LibMongoc_Dll;

{ int
  mongoc_gridfs_cnv_file_seek (mongoc_gridfs_file_t *file,
                               int64_t               delta,
                               int                   whence); }
  function mongoc_gridfs_cnv_file_seek(afile: Pointer;
                                       delta: Int64;
                                       whence: Integer): Integer;
  cdecl; external LibMongoc_Dll;

{ uint64_t
  mongoc_gridfs_cnv_file_tell (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_tell(afile: Pointer): UInt64;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_cnv_file_remove (mongoc_gridfs_cnv_file_t *file,
                                 bson_error_t             *error); }
  function mongoc_gridfs_cnv_file_remove(afile: Pointer;
                                         error: bson_error_p): UInt64;
  cdecl; external LibMongoc_Dll;

{ const char *
  mongoc_gridfs_cnv_file_get_filename (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_get_filename(afile: Pointer): PAnsiChar;
  cdecl; external LibMongoc_Dll;

{ int64_t
  mongoc_gridfs_cnv_file_get_length (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_get_length(afile: Pointer): Int64;
  cdecl; external LibMongoc_Dll;

{ int32_t
  mongoc_gridfs_cnv_file_get_chunk_size (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_get_chunk_size(afile: Pointer): LongInt;
  cdecl; external LibMongoc_Dll;

{ const char *
  mongoc_gridfs_file_get_content_type (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_get_content_type(afile: Pointer): PAnsiChar;
  cdecl; external LibMongoc_Dll;

{ const bson_t *
  mongoc_gridfs_file_get_aliases (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_get_aliases(afile: Pointer): bson_p;
  cdecl; external LibMongoc_Dll;

{ const bson_t *
  mongoc_gridfs_file_get_metadata (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_get_metadata(afile: Pointer): bson_p;
  cdecl; external LibMongoc_Dll;

{ const char *
  mongoc_gridfs_file_get_md5 (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_get_md5(afile: Pointer): PAnsiChar;
  cdecl; external LibMongoc_Dll;

{ int64_t
  mongoc_gridfs_file_get_upload_date (mongoc_gridfs_file_t *file); }
  function mongoc_gridfs_cnv_file_get_upload_date(afile: Pointer): Int64;
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_gridfs_cnv_file_set_content_type (mongoc_gridfs_file_t *file,
                                           const char           *content_type); }
  procedure mongoc_gridfs_cnv_file_set_content_type(afile: Pointer;
                                                    const content_type: PAnsiChar);
  cdecl; external LibMongoc_Dll;

 { void
  mongoc_gridfs_cnv_file_set_filename (mongoc_gridfs_file_t *file,
                                      const char           *filename); }
  procedure mongoc_gridfs_cnv_file_set_filename(afile: Pointer;
                                                const filename: PAnsiChar);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_gridfs_cnv_file_set_md5 (mongoc_gridfs_file_t *file,
                                  const char           *md5); }
  procedure mongoc_gridfs_cnv_file_set_md5(afile: Pointer;
                                           const md5: PAnsiChar);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_gridfs_cnv_file_set_metadata (mongoc_gridfs_file_t *file,
                                       const bson_t         *metadata); }
  procedure mongoc_gridfs_cnv_file_set_metadata(afile: Pointer;
                                                const metadata: bson_p);
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_cnv_file_is_encrypted (mongoc_gridfs_cnv_file_t *file); }
  function mongoc_gridfs_cnv_file_is_encrypted(afile: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_cnv_file_set_aes_key (mongoc_gridfs_cnv_file_t *file,
                                      const unsigned char      *aes_key,
                                      uint16_t                  aes_key_size); }
  function mongoc_gridfs_cnv_file_set_aes_key(afile: Pointer;
                                              const aes_key: PAnsiChar;
                                              aes_key_size: Word): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_cnv_file_set_aes_key_from_password (mongoc_gridfs_cnv_file_t *file,
                                                    const char               *password,
                                                    uint16_t                  password_size); }
  function mongoc_gridfs_cnv_file_set_aes_key_from_password(afile: Pointer;
                                                            const password: PAnsiChar;
                                                            password_size: Word): ByteBool;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_gridfs_cnv_file_is_compressed (mongoc_gridfs_cnv_file_t *file); }
  function mongoc_gridfs_cnv_file_is_compressed(afile: Pointer): ByteBool;
  cdecl; external LibMongoc_Dll;

{ int64_t
  mongoc_gridfs_cnv_file_get_compressed_length (mongoc_gridfs_cnv_file_t *file); }
  function mongoc_gridfs_cnv_file_get_compressed_length(afile: Pointer): Int64;
  cdecl; external LibMongoc_Dll;

implementation

initialization
  Assert(SizeOf(mongoc_index_opt_t) = {$IFDEF WIN64}120{$ELSE}64{$ENDIF},
         'keep structure synced with native c implementation');
  Assert(SizeOf(mongoc_host_list_t) = {$IFDEF WIN64}568{$ELSE}544{$ENDIF},
         'keep structure synced with native c implementation');

  mongoc_init;
finalization
  mongoc_cleanup;
end.

