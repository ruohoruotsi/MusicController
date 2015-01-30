//
//  DPMTableViewController.m
//  DPMusicControllerDemoApp
//
//  Created by Dan Pourhadi on 2/10/13.
//  Copyright (c) 2013 Dan Pourhadi. All rights reserved.
//

#import "DPMTableViewController.h"
#import "SVProgressHUD.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_OFF; // LOG_LEVEL_VERBOSE;


@interface DPMTableViewController ()
{
	BOOL loaded;
}

@end

@implementation DPMTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (!self.tableTitle) {
		self.tableTitle = @"";
	}

	NSArray *titleArray = @[@"Songs", @"Artists", @"Albums", self.tableTitle, @"Queue"];
	
	self.title = [titleArray objectAtIndex:self.tableContentType];
	
	[self reloadList];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList) name:kDPMusicNotificationLibraryLoaded object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList) name:kDPMusicNotificationPlaylistChanged object:nil];
    
    // Configure HUD
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.6 ]];
    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
}

- (void)reloadList
{
    // DDLogVerbose(@"self.tableContentType == %d", self.tableContentType);
    
	switch (self.tableContentType) {
		case DPMTableViewControllerContentTypeSongs:
			loaded = [[[DPMusicController sharedController] libraryManager] songsLoaded];
			self.items = [[DPMusicController sharedController] indexedSongs];
			break;
		case DPMTableViewControllerContentTypeArtists:
			loaded = [[[DPMusicController sharedController] libraryManager] artistsLoaded];
			self.items = [[DPMusicController sharedController] indexedArtists];
			break;
		case DPMTableViewControllerContentTypeAlbums:
			loaded = [[[DPMusicController sharedController] libraryManager] albumsLoaded];
			self.items = [[DPMusicController sharedController] indexedAlbums];
			
			break;
		case DPMTableViewControllerContentTypeDrillDown:
	
			break;
        case DPMTableViewControllerContentTypeQueue:
            loaded = ([[DPMusicController sharedController] queue].count > 0);
            self.items = [[DPMusicController sharedController] queue];
            break;
		default:
			break;
	}
	
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.tableContentType == DPMTableViewControllerContentTypeDrillDown ||
        self.tableContentType == DPMTableViewControllerContentTypeQueue) {

		return @"";
	}
	
	DPMusicItemIndexSection *indexSection = self.items[section];

	return indexSection.indexTitle;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView // {A, B, C, D ... X, Y, Z, #}
{
	if (self.tableContentType == DPMTableViewControllerContentTypeDrillDown ||
        self.tableContentType == DPMTableViewControllerContentTypeQueue) {
		return nil;
	}
	return [self valueForKeyPath:@"items.indexTitle"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (self.tableContentType == DPMTableViewControllerContentTypeDrillDown ||
        self.tableContentType == DPMTableViewControllerContentTypeQueue) {
		return 0;
	}
	return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // DDLogVerbose(@"self.tableContentType == %d", self.tableContentType);
    // DDLogVerbose(@"loaded == %d\n", loaded);
	
	if (!loaded && (self.tableContentType == DPMTableViewControllerContentTypeSongs ||
                    self.tableContentType == DPMTableViewControllerContentTypeArtists ||
                    self.tableContentType == DPMTableViewControllerContentTypeAlbums)) {
		return 0;
	}
	
	if (self.tableContentType == DPMTableViewControllerContentTypeDrillDown ||
        self.tableContentType == DPMTableViewControllerContentTypeQueue) {
        
		return 1;
	}
    
	return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // DDLogVerbose(@"self.tableContentType == %d", self.tableContentType);
    // DDLogVerbose(@"loaded == %d\n", loaded);
    
	if (!loaded && (self.tableContentType == DPMTableViewControllerContentTypeSongs ||
                    self.tableContentType == DPMTableViewControllerContentTypeArtists ||
                    self.tableContentType == DPMTableViewControllerContentTypeAlbums)) {
		return 0;
	}
	
	if (self.tableContentType == DPMTableViewControllerContentTypeDrillDown ||
        self.tableContentType ==  DPMTableViewControllerContentTypeQueue) {
		return self.items.count;
	}
	
	DPMusicItemIndexSection *indexSection = self.items[section];

	return indexSection.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // DDLogVerbose(@"self.tableContentType == %d", self.tableContentType);

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

	DPMusicItem *item;
	
	if (self.tableContentType == DPMTableViewControllerContentTypeDrillDown || self.tableContentType == DPMTableViewControllerContentTypeQueue) {
		item = self.items[indexPath.row];
	} else {
		DPMusicItemIndexSection *indexSection = self.items[indexPath.section];
		item = indexSection.items[indexPath.row]; 
	}
    
    
    cell.textLabel.text = item.generalTitle;
    cell.detailTextLabel.text = item.generalSubtitle;
    
    if (self.tableContentType == DPMTableViewControllerContentTypeAlbums) {
        cell.imageView.image = [item getRepresentativeImageForSize:CGSizeMake(44, 44)];
    }
	
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)addtoQueue:(DPMusicItem*)selectedItem atIndexPath:(NSIndexPath *)indexPath
{
    // Add to queue
    NSError *adderror = nil;
    
    [[DPMusicController sharedController] addSong:(DPMusicItemSong*)selectedItem error:&adderror];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Check error & notify
    if(!adderror) [SVProgressHUD showSuccessWithStatus:@"Added to Queue"];
    else [SVProgressHUD showErrorWithStatus:@"Already in Queue"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DPMusicItemIndexSection *indexSection = self.items[indexPath.section];
	
    // If indexSection == NIL, DPMTableViewControllerContentTypeDrillDown mode is active and
    // we need to display flat,non-sectioned data, i.e. album(s) songs or a flat list of songs
    if (([indexSection isKindOfClass:[DPMusicItemSong class]] ||
         [indexSection isKindOfClass:[DPMusicItemAlbum class]]) &&
        self.tableContentType == DPMTableViewControllerContentTypeDrillDown) {
        
        // Add to queue
        DPMusicItem *selectedItem = self.items[indexPath.row];
        [self addtoQueue:selectedItem atIndexPath:indexPath];
        
	} else if (self.tableContentType == DPMTableViewControllerContentTypeQueue) { // Special handling for queues

        DDLogVerbose(@" self.tableContentType == DPMTableViewControllerContentTypeQueue handler");
        
    } else {  // If there is a section index, we need to display sectioned data (i.e. artists, albums)
        
        DPMusicItem *selectedItem = indexSection.items[indexPath.row];
        
        if (self.tableContentType == DPMTableViewControllerContentTypeSongs) {
            
            // Add to queue
            [self addtoQueue:selectedItem atIndexPath:indexPath];
            
        } else if (self.tableContentType == DPMTableViewControllerContentTypeArtists) {
            
            DPMTableViewController *controller = [[DPMTableViewController alloc] initWithStyle:UITableViewStylePlain];
            controller.tableContentType = DPMTableViewControllerContentTypeDrillDown;
            
            // NSArray *albums = [(DPMusicItemArtist*)selectedItem albums]; // Return songs instead of albums! TODO FIXME
            NSArray *songs = [(DPMusicItemArtist*)selectedItem songs];
            controller.items = songs; // albums;
            controller.tableTitle = selectedItem.generalTitle;
            [self.navigationController pushViewController:controller animated:YES];
            
        } else if (self.tableContentType == DPMTableViewControllerContentTypeAlbums) {
            
            DPMTableViewController *controller = [[DPMTableViewController alloc] initWithStyle:UITableViewStylePlain];
            controller.tableContentType = DPMTableViewControllerContentTypeDrillDown;
            
            NSArray *songs = [(DPMusicItemAlbum*)selectedItem songs];
            controller.items = songs;
            controller.tableTitle = selectedItem.generalTitle;
            [self.navigationController pushViewController:controller animated:YES];
            
        }
    }
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
