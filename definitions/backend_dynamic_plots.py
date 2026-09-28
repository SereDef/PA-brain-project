import numpy as np

from nilearn import plotting
from nilearn.surface import load_surf_data

from matplotlib.colors import ListedColormap

from definitions.backend_calculations import fetch_surface, fetch_cont_colormap, fetch_discr_colormap
import definitions.layout_styles as styles


def dim_sulc(sulc, darkness=0.5):
    sulc = load_surf_data(sulc)
    s = (sulc - np.nanmin(sulc)) / np.ptp(sulc)   # -> [0,1]
    return 0.5 + (s - 0.5) * darkness             # compress around mid-grey; lower = dimmer

def plot_surfmap(min_beta, max_beta, n_clusters, sign_clusters, sign_betas,
                 surf='pial',  # 'pial', 'infl', 'flat', 'sphere'
                 resol='fsaverage6',
                 output='betas',
                 colorblind=False):

    fs_avg, n_nodes = fetch_surface(resol)

    brain3D = {}

    for nh, hemi in enumerate(['left', 'right']):

        if n_clusters[nh] == 0:
            brain3D[hemi] = plotting.plot_surf(
                surf_mesh=fs_avg[f'{surf}_{hemi}'],  # Surface mesh geometry
                surf_map=None,  # No statistical map
                bg_map=dim_sulc(fs_avg[f'sulc_{hemi}'], 0.3),
                hemi=hemi,
                view='lateral',
                engine='plotly',  # axes=axs[0] # only for matplotlib
                symmetric_cmap=True,
                colorbar=False).figure

            continue

        if output == 'clusters':
            stats_map = sign_clusters[hemi]

            max_val = n_clusters[nh]
            min_val = 1

            thresh = 1
            cmap = fetch_discr_colormap(hemi, 
                                        int(n_clusters[nh]), 
                                        int(n_clusters[0]+n_clusters[1]))

            if n_clusters[nh] != cmap.N:
                print(hemi, n_clusters[nh], cmap.N)

        else:
            stats_map = sign_betas[hemi]

            max_val = max_beta
            min_val = min_beta

            cmap, thresh = fetch_cont_colormap(stats_map = stats_map,
                                               max_val = max_val,
                                               min_val = min_val,
                                               colorblind = colorblind)
            
        # sym_cmap = min_val < 0
           
        brain3D[hemi] = plotting.plot_surf(
                surf_mesh=fs_avg[f'{surf}_{hemi}'],  # Surface mesh geometry
                surf_map=stats_map[:n_nodes],  # Statistical map
                bg_map=dim_sulc(fs_avg[f'sulc_{hemi}'], 0.3),
                hemi=hemi,
                view='lateral',
                engine='plotly',  # axes=axs[0] # only for matplotlib
                cmap=cmap,
                symmetric_cmap=False,  # sym_cmap,
                colorbar=False,
                vmin=min_val, vmax=max_val,
                threshold=thresh
            ).figure

    return brain3D


# ---------------------------------------------------------------------------------------------


def plot_overlap(overlap_maps, surf='pial', resol='fsaverage6'):

    fs_avg, n_nodes = fetch_surface(resol)

    cmap = ListedColormap([styles.OVLP_COLOR1, styles.OVLP_COLOR2, styles.OVLP_COLOR3])

    brain3D = {}

    for hemi in ['left', 'right']:

        brain3D[hemi] = plotting.plot_surf(
            surf_mesh=fs_avg[f'{surf}_{hemi}'],  # Surface mesh geometry
            surf_map=overlap_maps[hemi][:n_nodes],  # Statistical map
            bg_map=dim_sulc(fs_avg[f'sulc_{hemi}'], 0.3),
            hemi=hemi,
            view='lateral',
            engine='plotly',  # or matplolib # axes=axs[0] # only for matplotlib
            cmap=cmap,
            colorbar=False,
            vmin=1, vmax=3,
            threshold=1
        ).figure

    return brain3D
