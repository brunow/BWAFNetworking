## BWAFNetworking

Restfull http library inspired by the great RestKit and based on top of Afnetworking.

## Running example

If you want to play with the example you need to run the [Rails server](https://github.com/brunow/bwafnetworking_server).

Starting the server:

	bundle
	rake db:create
	rake db:migrate
	rails s

## BWAFNetworking api

	- (void)allObjects:(Class)objectClass
	           success:(BWAFNetworkingAllObjectsSuccessBlock)success
     	      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

	- (void)allObjects:(Class)objectClass
	        fromObject:(id)object
     	      success:(BWAFNetworkingAllObjectsSuccessBlock)success
	           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

	- (void)postObject:(id)object
     	      success:(BWAFNetworkingObjectSuccessBlock)success
	           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

	- (void)deleteObject:(id)object
     	        success:(BWAFNetworkingObjectSuccessBlock)success
			failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

	- (void)getObject:(id)object
          success:(BWAFNetworkingObjectSuccessBlock)success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

	- (void)putObject:(id)object
          success:(BWAFNetworkingObjectSuccessBlock)success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

	- (void)setSuccessDeleteBlock:(BWAFNetworkingSuccessDeleteObjectBlock)successDeleteBlock;


## ARC

BWAFNetworking is ARC only.

## Contact

Bruno Wernimont

- Twitter - [@brunowernimont](http://twitter.com/brunowernimont)