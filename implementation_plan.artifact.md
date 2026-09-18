# Data Hygiene: Purging Empty Leaf Nodes and Orphans

The goal is to ensure that the application only displays nodes that lead to actual educational content (PDFs or Book links). Currently, some nodes (leaf nodes) in the `full_nodes` Firestore collection are empty, leading to a poor user experience as shown in the provided screenshot.

## Proposed Changes

We will create and run a Python script to perform a recursive pruning of the `full_nodes` collection.

### Database Operations (`full_nodes` collection)

#### [MODIFY] `scratch/prune_empty_nodes.py` [NEW]
- This script will:
  1. Load all nodes from `full_nodes`.
  2. Identify the 12 protected root grade nodes (to prevent accidental deletion).
  3. Iteratively identify and delete "Empty Leaf Nodes":
     - A node is an "Empty Leaf" if it has no children AND its `resources` array is empty.
     - Once a child is deleted, its parent might become an Empty Leaf; the script will handle this iteratively.
  4. Identify and delete "Orphan Nodes":
     - Nodes with `parentId: None` or `parentId` pointing to a non-existent node (excluding protected grades).
  5. Log all deletions for verification.

## Verification Plan

### Automated Verification
- **Post-Prune Scan**: Run a final scan to ensure no leaf nodes without resources exist in `full_nodes`.
- **Count Comparison**: Compare the number of nodes before and after to verify the extent of the cleanup.

### Manual Verification
- **App Navigation**: Navigate through the app's hierarchy (specifically the paths that previously had empty pages) to confirm they no longer appear or lead to empty screens.
- **Home Page**: Verify the 12 main grades are still present and functioning.
