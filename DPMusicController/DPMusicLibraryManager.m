//
//  DPMusicLibraryManager.m
//  DPMusicControllerDemoApp
//
//  Created by Dan Pourhadi on 2/9/13.
//  Copyright (c) 2013 Dan Pourhadi. All rights reserved.
//

#import "DPMusicLibraryManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DPMusicItem.h"
#import "DPMusicItemIndexSection.h"
#import "DPMusicItemSong.h"
#import "DPMusicItemArtist.h"
#import "DPMusicItemAlbum.h"

#import <mach/mach_time.h>  // for mach_absolute_time() and friends


@interface DPMusicLibraryManager ()
{
	BOOL _songsLoaded;
	BOOL _artistsLoaded;
	BOOL _albumsLoaded;
}

@end

@implementation DPMusicLibraryManager

- (id)init
{
	self = [super init];
	if (self) {
        _includeUnplayable = YES;
		[self loadLibrary];
	}
	return self;
}

- (void)loadLibrary
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // TIMING BENCHMARKS
        mach_timebase_info_data_t info;
        if (mach_timebase_info(&info) != KERN_SUCCESS) return;
        
        //---------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------
        // SONG QUERY
        //---------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------

		MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
		__block NSMutableArray *songsArray = [NSMutableArray arrayWithCapacity:songsQuery.itemSections.count];
		
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            uint64_t start_songs = mach_absolute_time ();
            __block int count = 0;
            // DLog(@" songsQuery.itemSections size == %ld", (unsigned long)[songsQuery.itemSections count]);
            for (MPMediaQuerySection *section in songsQuery.itemSections) {
                NSArray *subArray = [songsQuery.items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:section.range]];
                NSMutableArray *convertedSubArray = [NSMutableArray arrayWithCapacity:subArray.count];
                
#if BLOCK_ENUM
                [subArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    MPMediaItem *item = obj;
                    if ([item valueForProperty:MPMediaItemPropertyAssetURL] || self.includeUnplayable) {
                        DPMusicItemSong *libraryItem = [[DPMusicItemSong alloc] initWithMediaItem:item];
                        libraryItem.libraryManager = self;
                        
                        [convertedSubArray addObject:libraryItem];
                        count++;
                    }
                }];
#else
                
                for (MPMediaItem *item in subArray) {
                    
                    if ([item valueForProperty:MPMediaItemPropertyAssetURL] || self.includeUnplayable) {
                        DPMusicItemSong *libraryItem = [[DPMusicItemSong alloc] initWithMediaItem:item];
                        libraryItem.libraryManager = self;
                        
                        [convertedSubArray addObject:libraryItem];
                        count++;
                    }
                }
#endif
                
                // DLog(@"  [SONG] convertedSubArray size == %ld", (unsigned long)[convertedSubArray count]);
                DPMusicItemIndexSection *itemSection = [[DPMusicItemIndexSection alloc] initWithItems:convertedSubArray forIndexTitle:section.title atIndex:songsArray.count];
                
                [songsArray addObject:itemSection];
            }

            _songs = [NSArray arrayWithArray:songsArray];
            DLog(@" SONG QUERY SUBARRAY ELEMENT COUNT == %d", count);
            DLog(@" songsArray COUNT == %d", [_songs count]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _songsLoaded = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kDPMusicNotificationLibraryLoaded object:nil];
                [self sectionLoaded];
            });
            
            
            uint64_t end_songs = mach_absolute_time ();
            uint64_t elapsed_songs = end_songs - start_songs;
            uint64_t nanos_songs = elapsed_songs * info.numer / info.denom;
            CGFloat ret_songs =  (CGFloat)nanos_songs / NSEC_PER_SEC;
            DLog(@" IOHAVOC -- SONG QUERY -- TIMING:::::::: %f", ret_songs);
        });
        
        
        //---------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------
        // ARTIST QUERY
        //---------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------
		
        MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
		NSMutableArray *artistsArray = [NSMutableArray arrayWithCapacity:artistsQuery.itemSections.count];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            uint64_t start_artists = mach_absolute_time ();
            int count = 0;
            // DLog(@" artistsQuery.itemSections size == %ld", (unsigned long)[artistsQuery.itemSections count]);
			
			for (MPMediaQuerySection *section in artistsQuery.collectionSections) {
				NSArray *subArray = [artistsQuery.collections objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:section.range]];
				NSMutableArray *convertedSubArray = [NSMutableArray arrayWithCapacity:subArray.count];
				
				for (MPMediaItemCollection *collection in subArray) {
					MPMediaItem *item = [collection representativeItem];
                    
					DPMusicItemArtist *libraryItem = [[DPMusicItemArtist alloc] initWithMediaItem:item];
					libraryItem.libraryManager = self;
                    [convertedSubArray addObject:libraryItem];
                     count++;
				}
				
                // DLog(@" [ARTIST] convertedSubArray size == %ld", (unsigned long)[convertedSubArray count]);
				DPMusicItemIndexSection *itemSection = [[DPMusicItemIndexSection alloc] initWithItems:convertedSubArray forIndexTitle:section.title atIndex:artistsArray.count];
				
				
				if (itemSection.items && itemSection.items.count > 0)
					[artistsArray addObject:itemSection];
			}
            
			_artists = [NSArray arrayWithArray:artistsArray];
            DLog(@" ARTIST QUERY SUBARRAY ELEMENT COUNT == %d", count);
            DLog(@" artistsArray COUNT == %d", [_artists count]);

			dispatch_async(dispatch_get_main_queue(), ^{
				_artistsLoaded = YES;
				[[NSNotificationCenter defaultCenter] postNotificationName:kDPMusicNotificationLibraryLoaded object:nil];
				[self sectionLoaded];
			});
            
            uint64_t end_artists = mach_absolute_time ();
            uint64_t elapsed_artists = end_artists - start_artists;
            uint64_t nanos_artists = elapsed_artists * info.numer / info.denom;
            CGFloat ret_artists =  (CGFloat)nanos_artists / NSEC_PER_SEC;
            DLog(@" IOHAVOC -- ARTIST QUERY -- TIMING:::::::: %f", ret_artists);
            
		});
        
        
        //---------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------
        // ALBUM QUERY
        //---------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------

		MPMediaQuery *albumsQuery = [MPMediaQuery albumsQuery];
		NSMutableArray *albumsArray = [NSMutableArray arrayWithCapacity:albumsQuery.itemSections.count];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            uint64_t start_albums = mach_absolute_time ();
            int count = 0;
			for (MPMediaQuerySection *section in albumsQuery.collectionSections) {
				NSArray *subArray = [albumsQuery.collections objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:section.range]];
				NSMutableArray *convertedSubArray = [NSMutableArray arrayWithCapacity:subArray.count];
				
				for (MPMediaItemCollection *collection in subArray) {
					MPMediaItem *item = [collection representativeItem];
					DPMusicItemAlbum *libraryItem = [[DPMusicItemAlbum alloc] initWithMediaItem:item];
					libraryItem.libraryManager = self;
                    [convertedSubArray addObject:libraryItem];
                    
                    count++;
				}
				
				DPMusicItemIndexSection *itemSection = [[DPMusicItemIndexSection alloc] initWithItems:convertedSubArray forIndexTitle:section.title atIndex:albumsArray.count];
				
				if (itemSection.items && itemSection.items.count > 0)
					[albumsArray addObject:itemSection];
			}
			
			
			_albums = [NSArray arrayWithArray:albumsArray];
            DLog(@" ALBUM QUERY SUBARRAY ELEMENT COUNT == %d", count);
            DLog(@" ALBUM SIZE == %ld", (unsigned long)[_albums count]);
			
            dispatch_async(dispatch_get_main_queue(), ^{
				_albumsLoaded = YES;
				[[NSNotificationCenter defaultCenter] postNotificationName:kDPMusicNotificationLibraryLoaded object:nil];
				[self sectionLoaded];
			});
            
            uint64_t end_albums = mach_absolute_time ();
            uint64_t elapsed_albums = end_albums - start_albums;
            uint64_t nanos_albums = elapsed_albums * info.numer / info.denom;
            CGFloat ret_albums =  (CGFloat)nanos_albums / NSEC_PER_SEC;
            DLog(@" IOHAVOC -- ALBUMS QUERY -- TIMING:::::::: %f", ret_albums);
		});
    });
}

- (void)sectionLoaded
{
	if (_artistsLoaded && _albumsLoaded && _songsLoaded) {
		_listsLoaded = YES;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kDPMusicNotificationLibraryLoaded object:nil];
		DLog(@"lists loaded");
        
        if (!self.includeUnplayable) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[self cleanUpUnplayable];
			});
        }
	}
}


- (DPMusicItemArtist*)artistForPersistentID:(NSNumber*)persistentID
{
	DPMusicItemArtist *artist;
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"persistentID == %@", persistentID];
	NSArray *allArtists = [self valueForKeyPath:@"artists.@unionOfArrays.items"];
	NSArray *filtered = [allArtists filteredArrayUsingPredicate:pred];
	
	if (filtered && filtered.count > 0) {
		artist = filtered[0];
	}
	return artist;
}
- (DPMusicItemAlbum*)albumForPersistentID:(NSNumber*)persistentID
{
	DPMusicItemAlbum *album;
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"persistentID == %@", persistentID];
	NSArray *allAlbums = [self valueForKeyPath:@"albums.@unionOfArrays.items"];
	NSArray *filtered = [allAlbums filteredArrayUsingPredicate:pred];
	
	if (filtered && filtered.count > 0)
		album = filtered[0];
	
	return album;
}

- (void)cleanUpUnplayable
{
    __weak __typeof(&*self)weakSelf = self;
       
        NSMutableArray *newSongArray = [NSMutableArray arrayWithCapacity:weakSelf.songs.count];
        
        for (DPMusicItemIndexSection *section in weakSelf.songs) {
            NSMutableArray *newItems = [NSMutableArray arrayWithCapacity:section.items.count];
            
            for (DPMusicItemSong *song in section.items) {
                if (song.url) {
                    [newItems addObject:song];
                }
            }
            
            if (newItems.count > 0) {
                DPMusicItemIndexSection *newSection = [[DPMusicItemIndexSection alloc] initWithItems:newItems forIndexTitle:section.indexTitle atIndex:section.sectionIndex];
                [newSongArray addObject:newSection];
            }
        }
        
        _songs = newSongArray;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        NSMutableArray *newArtistArray = [NSMutableArray arrayWithCapacity:weakSelf.artists.count];
        
        for (DPMusicItemIndexSection *section in weakSelf.artists) {
            
            NSMutableArray *newItems = [NSMutableArray arrayWithCapacity:section.items.count];
            
            for (DPMusicItemArtist *artist in section.items) {
                NSArray *songs = artist.songs;
                
                if (songs && songs.count > 0) {
                    [newItems addObject:artist];
                }
                
            }
            
            if (newItems.count > 0) {
                DPMusicItemIndexSection *newSection = [[DPMusicItemIndexSection alloc] initWithItems:newItems forIndexTitle:section.indexTitle atIndex:section.sectionIndex];
                [newArtistArray addObject:newSection];
            }
            
        }
        
        _artists = newArtistArray;
	});
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        NSMutableArray *newAlbumArray = [NSMutableArray arrayWithCapacity:weakSelf.albums.count];
        
        for (DPMusicItemIndexSection *section in weakSelf.albums) {
            
            NSMutableArray *newItems = [NSMutableArray arrayWithCapacity:section.items.count];
            
            for (DPMusicItemAlbum *album in section.items) {
                NSArray *songs = album.songs;
                
                if (songs && songs.count > 0) {
                    [newItems addObject:album];
                }
                
            }
            
            if (newItems.count > 0) {
                DPMusicItemIndexSection *newSection = [[DPMusicItemIndexSection alloc] initWithItems:newItems forIndexTitle:section.indexTitle atIndex:section.sectionIndex];
                [newAlbumArray addObject:newSection];
            }
            
        }
        
        _albums = newAlbumArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [[NSNotificationCenter defaultCenter] postNotificationName:kDPMusicNotificationLibraryLoaded object:nil];
            
        });

    });
}

@end
