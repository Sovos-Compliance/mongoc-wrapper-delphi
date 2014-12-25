unit uLibMongocAPI;

interface

uses
  Windows, SysUtils, LibBsonAPI, MongoBson, uMongoReadPrefs, uDelphi5;

const
  LibMongoc_Dll = LibBson_DLL;

//

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
  function mongoc_read_prefs_is_valid(const read_prefs: Pointer): Byte;
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
                                        error: bson_error_p): Byte;
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
                                           error: bson_error_p): Byte;
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
  function mongoc_write_concern_get_fsync(const write_concern: Pointer): Byte;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_write_concern_get_journal (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_journal(const write_concern: Pointer): Byte;
  cdecl; external LibMongoc_Dll;

{ int32_t
  mongoc_write_concern_get_w (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_w(const write_concern: Pointer): LongInt;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_write_concern_get_wmajority (const mongoc_write_concern_t *write_concern); }
  function mongoc_write_concern_get_wmajority(const write_concern: Pointer): Byte;
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
                                           fsync_: Byte);
  cdecl; external LibMongoc_Dll;

{ void
  mongoc_write_concern_set_journal (mongoc_write_concern_t *write_concern,
                                    bool                    journal); }
  procedure mongoc_write_concern_set_journal(write_concern: Pointer;
                                             journal: Byte);
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
  function mongoc_database_drop(database: Pointer; error: bson_error_p): Byte;
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
                                    error: bson_error_p): Byte;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_database_remove_all_users (mongoc_database_t *database,
                                    bson_error_t      *error); }
  function mongoc_database_remove_all_users(database: Pointer;
                                            error: bson_error_p): Byte;
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
                                          error: bson_error_p): Byte;
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
                                          error: bson_error_p): Byte;
  cdecl; external LibMongoc_Dll;

{ bool
  mongoc_database_remove_user (mongoc_database_t *database,
                               const char        *username,
                               bson_error_t      *error); }
  function mongoc_database_remove_user(database: Pointer;
                                       const username: PAnsiChar;
                                       error: bson_error_p): Byte;
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

implementation

initialization
  mongoc_init;
finalization
  mongoc_cleanup;
end.

